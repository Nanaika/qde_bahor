import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_eco_bahor/core/utils/time_utils.dart';
import 'package:qde_eco_bahor/features/admin/add_product/add_product_event.dart';

import '../add_product/add_product_bloc.dart';
import '../add_product/add_product_state.dart';
import '../manage_products/manage_products_bloc.dart';
import '../manage_products/manage_products_event.dart';
import '../manage_products/manage_products_state.dart';
import '../models/product_model.dart';
import '../models/product_variant.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ManageProductsBloc>().add(GetProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Manage products'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: () {
              context.push('/add_product');
            },
          ),
        ],
      ),
      body: BlocListener<AddProductBloc, AddProductState>(
        listener: (context, state) {
          if (state is AddProductLoading) {
            context
                .read<ManageProductsBloc>()
                .add(SetLoadingEvent()); // Ивент, который делает emit(ManageProductsLoading())
          }
          if (state is AddProductSuccess) {
            // 1. Триггерим обновление списка в основном блоке
            context.read<ManageProductsBloc>().add(GetProductsEvent()); // Укажи свое название ивента
          }
        },
        child: BlocBuilder<ManageProductsBloc, ManageProductsState>(
          builder: (context, state) {
            // 1. Состояние загрузки
            if (state is ManageProductsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // 2. Состояние ошибки
            if (state is ManageProductsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        'Error: ${state.failure.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          // Повторный запрос данных
                          context.read<ManageProductsBloc>().add(GetProductsEvent());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // 3. Состояние успеха
            if (state is ManageProductsSuccess) {
              final products = state.products;

              // Если список пуст
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No products',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              // Список товаров
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: product.photoUrl.isNotEmpty
                                    ? Image.network(
                                        product.photoUrl,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.grey.shade100,
                                          child: const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                                        ),
                                      )
                                    : Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey.shade100,
                                        child: const Icon(Icons.image_not_supported, size: 32, color: Colors.grey),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        // color: theme.primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${product.productType.name}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          // color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    if (product.date != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product.date?.toFormattedString()}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
                                    onPressed: () {
                                      context.push('/add_product', extra: product);
                                    },
                                  ),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                                    onPressed: () {
                                      _showDeleteDialog(context, product.id!);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (product.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                            ),
                          ],
                          if (product.variants.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1),
                            ),
                            const Text(
                              'Variants:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: product.variants.map((variant) {
                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    // color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        variant.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Price: ${variant.price} | Vol: ${variant.value} ${variant.unit.name}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        'Netto: ${variant.netWeight}kg | Gross: ${variant.grossWeight}kg',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ProductPromoButton(
                                  product: product,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

void _showDeleteDialog(BuildContext context, String typeId) {
  showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: const Text('Delete product?'),
      content: const Text('It is cannot be undone'),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true, // Делает текст красным
          onPressed: () {
            Navigator.pop(ctx);

            // Вызов события BLoC или функции удаления:
            context.read<AddProductBloc>().add(DeleteEvent(typeId));
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

class ProductPromoButton extends StatelessWidget {
  final ProductModel product;

  const ProductPromoButton({
    super.key,
    required this.product,
  });

  bool get _hasAnyPromo => product.variants.any((v) => v.buyQuantity > 0 && v.freeQuantity > 0);

  void _showPromoBottomSheet(BuildContext context) {
    if (product.variants.isEmpty) return;

    // Локальный массив вариантов для работы в памяти
    final List<ProductVariant> localVariants = List.from(product.variants);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setStateModal) {
            // Проверка: изменилось ли хоть одно поле
            bool isChanged() {
              for (int i = 0; i < product.variants.length; i++) {
                final orig = product.variants[i];
                final local = localVariants[i];
                if (orig.buyQuantity != local.buyQuantity || orig.freeQuantity != local.freeQuantity) {
                  return true;
                }
              }
              return false;
            }

            final canSave = isChanged();

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bonus (N + M)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Список всех вариантов
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: localVariants.length,
                      separatorBuilder: (_, __) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final variant = localVariants[index];

                        return _PromoVariantItemTile(
                          key: ValueKey(variant.id),
                          variant: variant,
                          onChanged: (updatedVariant) {
                            localVariants[index] = updatedVariant;
                            setStateModal(() {}); // Обновляем состояние кнопки "Сохранить"
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Кнопка сохранения
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: canSave
                          ? () {
                              context.read<ManageProductsBloc>().add(
                                    UpdateProductVariantsEvent(
                                      product: product.copyWith(variants: localVariants),
                                    ),
                                  );
                              Navigator.pop(ctx);
                            }
                          : null,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPromoBottomSheet(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _hasAnyPromo ? Colors.orange.withOpacity(0.15) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hasAnyPromo ? Colors.orange : Colors.grey.shade400,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 18,
              color: _hasAnyPromo ? Colors.orange.shade800 : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              _hasAnyPromo ? 'Bonus active' : 'Bonus inactive',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _hasAnyPromo ? Colors.orange.shade900 : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoVariantItemTile extends StatefulWidget {
  final ProductVariant variant;
  final ValueChanged<ProductVariant> onChanged;

  const _PromoVariantItemTile({
    super.key,
    required this.variant,
    required this.onChanged,
  });

  @override
  State<_PromoVariantItemTile> createState() => _PromoVariantItemTileState();
}

class _PromoVariantItemTileState extends State<_PromoVariantItemTile> {
  late final TextEditingController buyController;
  late final TextEditingController freeController;

  @override
  void initState() {
    super.initState();
    buyController = TextEditingController(
      text: widget.variant.buyQuantity > 0 ? widget.variant.buyQuantity.toString() : '',
    );
    freeController = TextEditingController(
      text: widget.variant.freeQuantity > 0 ? widget.variant.freeQuantity.toString() : '',
    );
  }

  @override
  void dispose() {
    buyController.dispose();
    freeController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    final buy = int.tryParse(buyController.text) ?? 0;
    final free = int.tryParse(freeController.text) ?? 0;

    widget.onChanged(
      widget.variant.copyWith(
        buyQuantity: buy,
        freeQuantity: free,
      ),
    );
  }

  void _clear() {
    buyController.clear();
    freeController.clear();
    setState(() {});
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    final hasPromo = (int.tryParse(buyController.text) ?? 0) > 0 && (int.tryParse(freeController.text) ?? 0) > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.variant.name,
                maxLines: 2,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              width: 22,
            ),
            if (hasPromo)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: _clear,
              ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: buyController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  setState(() {});
                  _notifyParent();
                },
                decoration: InputDecoration(
                  labelText: 'Purchase (N)',
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                  ),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: TextField(
                controller: freeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  setState(() {});
                  _notifyParent();
                },
                decoration: InputDecoration(
                  labelText: 'Bonus (M)',
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                  ),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 12,
        ),
      ],
    );
  }
}
