import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/features/admin/manage_products/manage_products_bloc.dart';
import 'package:qde_eco_bahor/features/admin/manage_products/manage_products_event.dart';
import 'package:qde_eco_bahor/features/admin/manage_products/manage_products_state.dart';

import '../models/product_model.dart';
import '../models/product_variant.dart';
import '../discount/discount_bloc.dart';
import '../discount/discount_event.dart';
import '../discount/discount_model.dart';
import '../discount/discount_state.dart';

class DiscountsPage extends StatelessWidget {
  final String userId;

  const DiscountsPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscountsBloc()..add(FetchUserDiscountsEvent(userId)),
      child: _UserDiscountsView(userId: userId),
    );
  }
}

class _UserDiscountsView extends StatelessWidget {
  final String userId;

  const _UserDiscountsView({
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discounts'.tr()),
        // Кнопка добавления в верхнем баре
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Discount'.tr(),
            onPressed: () => _showDiscountForm(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<DiscountsBloc, DiscountsState>(
        listenWhen: (previous, current) {
          if (previous is DiscountsLoadedState && current is DiscountsLoadedState) {
            return previous.isActionInProgress != current.isActionInProgress;
          }
          return current is DiscountsErrorState;
        },
        listener: (context, state) {
          if (state is DiscountsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<DiscountsBloc, DiscountsState>(
          builder: (context, state) {
            if (state is DiscountsLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DiscountsErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<DiscountsBloc>().add(FetchUserDiscountsEvent(userId));
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text('Retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            if (state is DiscountsLoadedState) {
              if (state.discounts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'No discounts found for this user.'.tr(),
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _showDiscountForm(context),
                        icon: const Icon(Icons.add),
                        label: Text('Create First Discount'.tr()),
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.discounts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final discount = state.discounts[index];
                      return _buildDiscountCard(context, discount);
                    },
                  ),
                  if (state.isActionInProgress)
                    const ModalBarrier(
                      dismissible: false,
                      color: Colors.black26,
                    ),
                  if (state.isActionInProgress)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDiscountCard(BuildContext context, DiscountModel discount) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_offer_outlined, color: Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    discount.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  if (discount.productVariant.isNotEmpty)
                    Text(
                      'variant_label'.tr(args: [discount.productVariant.toString()]),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${discount.discountPercent}%',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showDiscountForm(context, discount: discount),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () {
                context.read<DiscountsBloc>().add(
                      DeleteDiscountEvent(
                        userId: userId,
                        discountId: discount.id,
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDiscountForm(
    BuildContext context, {
    DiscountModel? discount,
  }) {
    final isEditing = discount != null;

    final discountsBloc = context.read<DiscountsBloc>();
    final productsBloc = context.read<ManageProductsBloc>();

    if (productsBloc.state is ManageProductsInitial) {
      productsBloc.add(GetProductsEvent());
    }

    ProductModel? selectedProduct;
    ProductVariant? selectedVariant;

    final percentController = TextEditingController(
      text: discount != null ? discount.discountPercent.toString() : '',
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: discountsBloc),
            BlocProvider.value(value: productsBloc),
          ],
          child: BlocBuilder<ManageProductsBloc, ManageProductsState>(
            bloc: productsBloc,
            builder: (context, productsState) {
              if (productsState is ManageProductsLoading || productsState is ManageProductsInitial) {
                return SizedBox(
                  height: 250,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text('Loading products...'.tr()),
                      ],
                    ),
                  ),
                );
              }

              if (productsState is! ManageProductsSuccess) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Failed to load products'.tr()),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => productsBloc.add(GetProductsEvent()),
                          child: Text('Retry'.tr()),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final products = productsState.products;

              return StatefulBuilder(
                builder: (context, setSheetState) {
                  // Binding data strictly by ID
                  if (isEditing && selectedProduct == null && products.isNotEmpty) {
                    try {
                      selectedProduct = products.firstWhere(
                        (p) => p.id == discount.productId,
                        orElse: () => products.first,
                      );

                      selectedVariant = selectedProduct!.variants.firstWhere(
                        (v) => v.id == discount.variantId,
                        orElse: () => selectedProduct!.variants.first,
                      );
                    } catch (_) {
                      selectedProduct = products.first;
                    }
                  }

                  final availableVariants = selectedProduct?.variants ?? [];

                  return Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                      bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16.0,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Discount'.tr() : 'Add New Discount'.tr(),
                            style: Theme.of(sheetContext).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          // 1. Select Product by ID
                          DropdownButtonFormField<String>(
                            initialValue: selectedProduct?.id,
                            decoration: InputDecoration(
                              labelText: 'Select Product'.tr(),
                              border: const OutlineInputBorder(),
                            ),
                            items: products.map((product) {
                              return DropdownMenuItem<String>(
                                value: product.id,
                                child: Text(product.name),
                              );
                            }).toList(),
                            onChanged: (String? newProductId) {
                              if (newProductId == null) return;
                              setSheetState(() {
                                selectedProduct = products.firstWhere(
                                  (p) => p.id == newProductId,
                                );
                                selectedVariant = null;
                              });
                            },
                            validator: (val) => val == null ? 'Please select a product'.tr() : null,
                          ),
                          const SizedBox(height: 12),

                          // 2. Select Variant by ID (With Duplicate Check)
                          DropdownButtonFormField<String>(
                            initialValue: selectedVariant?.id,
                            decoration: InputDecoration(
                              labelText: 'Select Variant'.tr(),
                              border: const OutlineInputBorder(),
                            ),
                            items: availableVariants.map((variant) {
                              return DropdownMenuItem<String>(
                                value: variant.id,
                                child: Text(variant.name),
                              );
                            }).toList(),
                            onChanged: availableVariants.isNotEmpty
                                ? (String? newVariantId) {
                                    if (newVariantId == null) return;
                                    setSheetState(() {
                                      selectedVariant = availableVariants.firstWhere(
                                        (v) => v.id == newVariantId,
                                      );
                                    });
                                  }
                                : null,
                            validator: (val) {
                              if (availableVariants.isNotEmpty && val == null) {
                                return 'Please select a variant'.tr();
                              }

                              // DUPLICATE VALIDATION IN UI
                              final currentDiscountsState = discountsBloc.state;
                              if (currentDiscountsState is DiscountsLoadedState) {
                                final targetProductId = selectedProduct?.id ?? '';
                                final targetVariantId = val ?? '';

                                final isDuplicate = currentDiscountsState.discounts.any(
                                  (d) =>
                                      d.productId == targetProductId &&
                                      d.variantId == targetVariantId &&
                                      d.id != (discount?.id ?? ''),
                                );

                                if (isDuplicate) {
                                  return 'Discount for this variant already exists'.tr();
                                }
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // 3. Discount Percent
                          TextFormField(
                            controller: percentController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Discount %'.tr(),
                              border: const OutlineInputBorder(),
                              suffixText: '%'.tr(),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Enter discount %'.tr();
                              }
                              final numVal = double.tryParse(val);
                              if (numVal == null || numVal <= 0 || numVal > 100) {
                                return 'Enter a valid percent (1-100)'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  final newDiscount = DiscountModel(
                                    id: discount?.id ?? '',
                                    productId: selectedProduct!.id!,
                                    productName: selectedProduct!.name,
                                    variantId: selectedVariant?.id ?? '',
                                    productVariant: selectedVariant?.name ?? '',
                                    discountPercent: double.parse(
                                      percentController.text.trim(),
                                    ),
                                  );

                                  context.read<DiscountsBloc>().add(
                                        SaveDiscountEvent(
                                          userId: userId,
                                          discount: newDiscount,
                                        ),
                                      );

                                  Navigator.pop(sheetContext);
                                }
                              },
                              child: Text(
                                isEditing ? 'Save Changes'.tr() : 'Add Discount'.tr(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
