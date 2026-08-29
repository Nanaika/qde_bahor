import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_eco_bahor/core/utils/time_utils.dart';
import 'package:qde_eco_bahor/features/admin/add_product/add_product_event.dart';

import '../add_product/add_product_bloc.dart';
import '../add_product/add_product_state.dart';
import '../manage_products/manage_products_bloc.dart';
import '../manage_products/manage_products_event.dart';
import '../manage_products/manage_products_state.dart';

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
                                        color: theme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${product.productType.name}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: theme.primaryColor,
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
                          if (product.description != null && product.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${product.description}',
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
                                    color: Colors.grey.shade50,
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
                                        style: const TextStyle(fontSize: 11, color: Colors.black87),
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
