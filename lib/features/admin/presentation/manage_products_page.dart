import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      body: BlocBuilder<ManageProductsBloc, ManageProductsState>(
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
                print('===============${product.productType.id}');
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
                      product.name ?? 'Без названия',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      children: [
                        Text(
                          '${product.date ?? 0}',
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
                            // TODO: Редактировать товар
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // TODO: Удалить товар
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
    );
  }
}
