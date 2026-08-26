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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Переход на страницу добавления товара
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.failure.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Повторный запрос данных
                        context.read<ManageProductsBloc>().add(GetProductsEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // 3. Состояние успеха
            if (state is ManageProductsSuccess) {
              final products = state.products;

              // Если список пуст
              if (products.isEmpty) {
                return const Center(
                  child: Text('No products'),
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
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: product.photoUrl.isNotEmpty
                          ? Image.network(
                              product.photoUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
                            )
                          : const Icon(Icons.image_not_supported, size: 40),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        children: [
                          Text(
                            '${product.date?.toFormattedString()}',
                          ),
                          Text(
                            '${product.productType.name}',
                          ),
                          Text(
                            '${product.description}',
                          ),
                          Column(
                            children: product.variants.map((variant) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Column(
                                  children: [
                                    Text(variant.name),
                                    Text(variant.price.toString()),
                                    Text(variant.value.toString()),
                                    Text(variant.unit.name),
                                    Text(variant.grossWeight.toString()),
                                    Text(variant.netWeight.toString()),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              context.push('/add_product', extra: product);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteDialog(context, product.id!);
                            },
                          ),
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
