import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/features/admin/manage_products/manage_products_bloc.dart';
import 'package:qde_eco_bahor/features/admin/manage_products/manage_products_event.dart';
import 'package:qde_eco_bahor/features/admin/manage_products/manage_products_state.dart';

import '../../models/product_model.dart';
import '../restricted_product_model.dart';
import '../restricted_products_bloc.dart';
import '../restricted_products_event.dart';
import '../restricted_products_state.dart';

class RestrictedProductsPage extends StatelessWidget {
  final String userId;

  const RestrictedProductsPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RestrictedProductsBloc()..add(LoadRestrictedProductsEvent(userId)),
      child: _UserRestrictedProductsView(userId: userId),
    );
  }
}

class _UserRestrictedProductsView extends StatelessWidget {
  final String userId;

  const _UserRestrictedProductsView({
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Restriction',
            onPressed: () => _showRestrictionForm(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<RestrictedProductsBloc, RestrictedProductsState>(
        listener: (context, state) {
          if (state is RestrictedProductsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<RestrictedProductsBloc, RestrictedProductsState>(
          builder: (context, state) {
            if (state is RestrictedProductsLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RestrictedProductsErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<RestrictedProductsBloc>().add(LoadRestrictedProductsEvent(userId));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is RestrictedProductsSuccessState) {
              if (state.restrictions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.block_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        'No restricted products found for this user.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _showRestrictionForm(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Restriction'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.restrictions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final restriction = state.restrictions[index];
                  return _buildRestrictionCard(context, restriction);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRestrictionCard(BuildContext context, RestrictedProductModel restriction) {
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
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.block_outlined, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restriction.productName.isNotEmpty ? restriction.productName : restriction.productId,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    'ID: ${restriction.productId}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // IconButton(
            //   icon: const Icon(Icons.edit_outlined, size: 20),
            //   onPressed: () => _showRestrictionForm(context, restriction: restriction),
            // ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () {
                context.read<RestrictedProductsBloc>().add(
                      DeleteRestrictedProductEvent(
                        userId: userId,
                        productId: restriction.productId,
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRestrictionForm(
    BuildContext context, {
    RestrictedProductModel? restriction,
  }) {
    final isEditing = restriction != null;

    final restrictedProductsBloc = context.read<RestrictedProductsBloc>();
    final productsBloc = context.read<ManageProductsBloc>();

    if (productsBloc.state is ManageProductsInitial) {
      productsBloc.add(GetProductsEvent());
    }

    ProductModel? selectedProduct;
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
            BlocProvider.value(value: restrictedProductsBloc),
            BlocProvider.value(value: productsBloc),
          ],
          child: BlocBuilder<ManageProductsBloc, ManageProductsState>(
            bloc: productsBloc,
            builder: (context, productsState) {
              if (productsState is ManageProductsLoading || productsState is ManageProductsInitial) {
                return const SizedBox(
                  height: 250,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Loading products...'),
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
                        const Text('Failed to load products'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => productsBloc.add(GetProductsEvent()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final products = productsState.products;

              return StatefulBuilder(
                builder: (context, setSheetState) {
                  if (isEditing && selectedProduct == null && products.isNotEmpty) {
                    try {
                      selectedProduct = products.firstWhere(
                        (p) => p.id == restriction.productId,
                        orElse: () => products.first,
                      );
                    } catch (_) {
                      selectedProduct = products.first;
                    }
                  }

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
                            isEditing ? 'Edit Restriction' : 'Add New Restriction',
                            style: Theme.of(sheetContext).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          // Выбор товара из справочника
                          DropdownButtonFormField<String>(
                            value: selectedProduct?.id,
                            decoration: const InputDecoration(
                              labelText: 'Select Product',
                              border: OutlineInputBorder(),
                            ),
                            items: products.map((product) {
                              return DropdownMenuItem<String>(
                                value: product.id,
                                child: Text(product.name),
                              );
                            }).toList(),
                            onChanged: isEditing
                                ? null
                                : (String? newProductId) {
                                    if (newProductId == null) return;
                                    setSheetState(() {
                                      selectedProduct = products.firstWhere(
                                        (p) => p.id == newProductId,
                                      );
                                    });
                                  },
                            validator: (val) {
                              if (val == null) return 'Please select a product';

                              final currentRestrictionsState = restrictedProductsBloc.state;
                              if (currentRestrictionsState is RestrictedProductsSuccessState) {
                                final isDuplicate = currentRestrictionsState.restrictions.any(
                                  (r) => r.productId == val && r.productId != (restriction?.productId ?? ''),
                                );

                                if (isDuplicate) {
                                  return 'Restriction for this product already exists';
                                }
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Кнопка Сохранить/Добавить
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  final newRestriction = RestrictedProductModel(
                                    productId: selectedProduct!.id!,
                                    productName: selectedProduct!.name,
                                  );

                                  if (isEditing) {
                                    context.read<RestrictedProductsBloc>().add(
                                          UpdateRestrictedProductEvent(
                                            userId: userId,
                                            restriction: newRestriction,
                                          ),
                                        );
                                  } else {
                                    context.read<RestrictedProductsBloc>().add(
                                          AddRestrictedProductEvent(
                                            userId: userId,
                                            restriction: newRestriction,
                                          ),
                                        );
                                  }

                                  Navigator.pop(sheetContext);
                                }
                              },
                              child: Text(
                                isEditing ? 'Save Changes' : 'Add Restriction',
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
