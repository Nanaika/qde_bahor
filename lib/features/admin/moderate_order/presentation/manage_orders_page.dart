import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../cart/cart_item.dart';
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
            print('ORDERS error=====================  ${state.message}');
            return Center(child: Text(state.message));
          }

          if (state is ManageOrdersSuccess) {
            print('ORDERS =====================  ${state.orders}');

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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Заказ #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${order.totalPrice} сум',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (dateFormatted.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                dateFormatted,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            const Divider(height: 16),

            // Проход по элементам заказа CartItem
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.product.name} (${item.variant.name})',
                        ),
                      ),
                      Text('${item.quantity} шт.'),
                      const SizedBox(width: 12),
                      Text('${item.totalPrice} сум'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
