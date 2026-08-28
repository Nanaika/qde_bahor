import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../manage_order_state.dart';
import '../manage_orders_bloc.dart';
import '../manage_orders_event.dart';
import '../order_model.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  @override
  void initState() {
    super.initState();
    context.read<ManageOrdersBloc>().add(const SubscribeToManageOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказы'),
      ),
      body: BlocBuilder<ManageOrdersBloc, ManageOrdersState>(
        builder: (context, state) {
          if (state is ManageOrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ManageOrdersError) {
            return Center(child: Text(state.message));
          }

          if (state is ManageOrdersSuccess) {
            if (state.orders.isEmpty) {
              return const Center(child: Text('Заказов нет'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _OrderCard(order: order);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = order.createdAt != null ? DateFormat('dd.MM.yyyy HH:mm').format(order.createdAt!) : '';
    final double totalNetto = order.items.fold(
      0,
      (sum, item) => sum + ((item.variant.netWeight ?? 0) * item.quantity),
    );

    final double totalBrutto = order.items.fold(
      0,
      (sum, item) => sum + ((item.variant.grossWeight ?? 0) * item.quantity),
    );

    // 2. Цены: Обычная (без скидки) и итоговая (со скидкой)
    final double totalOriginalPrice = order.items.fold(
      0.0,
      (sum, item) => sum + (item.variant.price * item.quantity),
    );
    final double totalDiscountedPrice = order.items.fold(
      0.0,
      (sum, item) => sum + (item.variant.price * item.quantity),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Заказ #${order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (dateFormatted.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                dateFormatted,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            const Divider(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${order.owner.name}',
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
                Text(
                  '${order.owner.company}',
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
                Text(
                  '${order.owner.number}',
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
              ],
            ),

            // Проход по элементам заказа CartItem

            const Divider(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];

                // Вес НЕТТО и БРУТТО для конкретного товара
                final double itemNetto = (item.variant.netWeight ?? 0) * item.quantity;
                final double itemBrutto = (item.variant.grossWeight ?? 0) * item.quantity;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.product.name} (${item.variant.name})',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Нетто: $itemNetto кг  •  Брутто: $itemBrutto кг',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('${item.quantity} шт.'),
                                const SizedBox(width: 12),
                                Text(
                                  '${item.totalPrice} сум',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: const Text(
                          'Общий вес заказа:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'Нетто: ${totalNetto.toStringAsFixed(2)} кг / Брутто: ${totalBrutto.toStringAsFixed(2)} кг',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Итого к оплате:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${totalOriginalPrice} сум',
                            style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.outline,
                                decoration: TextDecoration.lineThrough),
                          ),
                          Text(
                            '${totalDiscountedPrice} сум',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7000FF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
          ],
        ),
      ),
    );
  }
}
