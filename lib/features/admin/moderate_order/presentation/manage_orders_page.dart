import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qde_eco_bahor/features/admin/moderate_order/status_type.dart';

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
                const Text(
                  'User',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
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
                          textAlign: TextAlign.end,
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
            GestureDetector(
              onTap: () {
                showStatusPickerBottomSheet(
                  context,
                  title: 'Select status',
                  currentStatus: order.warehouseStatus,
                  id: order.id,
                  statusType: StatusType.storage,
                );
              },
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Warehouse Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    buildStatusRow(order.warehouseStatus),
                    const SizedBox(
                      height: 10,
                    ),
                    if (order.warehouseStatus == OrderStatus.declined)
                      Column(
                        children: [
                          Text('Declined reason'),
                          SizedBox(
                            height: 10,
                          ),
                          Text(order.warehouseDeclinedMessage),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const Divider(height: 16),
            GestureDetector(
              onTap: () {
                showStatusPickerBottomSheet(
                  context,
                  title: 'Select status',
                  currentStatus: order.accountingStatus,
                  id: order.id,
                  statusType: StatusType.accounting,
                );
              },
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accounting Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    buildStatusRow(order.accountingStatus),
                    const SizedBox(
                      height: 10,
                    ),
                    if (order.accountingStatus == OrderStatus.declined)
                      Column(
                        children: [
                          Text('Declined reason'),
                          SizedBox(
                            height: 10,
                          ),
                          Text(order.accountingDeclinedMessage),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildStatusRow(OrderStatus status) {
  // Определяем цвет и текст статуса
  Color statusColor;
  Color statusTextColor;
  String statusText;

  switch (status) {
    case OrderStatus.accepted:
      statusColor = const Color(0xFFE8F5E9);
      statusTextColor = const Color(0xFF2E7D32);
      statusText = 'Accepted';
      break;
    case OrderStatus.declined:
      statusColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFC62828);
      statusText = 'Declined';
      break;
    case OrderStatus.waiting:
      statusColor = const Color(0xFFFFF8E1);
      statusTextColor = Colors.amber;
      statusText = 'Waiting';
      break;
  }

  return Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: statusTextColor,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          statusText,
          style: TextStyle(
            color: statusTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}

enum OrderStatus { waiting, accepted, declined }

Future<OrderStatus?> showStatusPickerBottomSheet(
  BuildContext context, {
  required String title,
  required OrderStatus currentStatus,
  required String id,
  required StatusType statusType,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final reasonController = TextEditingController();

  return showModalBottomSheet<OrderStatus>(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Status List
                    ...OrderStatus.values.map((status) {
                      final isSelected = status == currentStatus;
                      final color = _getStatusColor(status);
                      final isDeclinedStatus = status == OrderStatus.declined;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (isDeclinedStatus) {
                                  // Переключаем статус без закрытия, чтобы открыть поле
                                  setState(() {
                                    currentStatus = OrderStatus.declined;
                                  });
                                } else {
                                  context.read<ManageOrdersBloc>().add(
                                        UpdateStatusEvent(
                                          docId: id,
                                          statusType: statusType,
                                          status: status,
                                          reason: '',
                                        ),
                                      );
                                  Navigator.pop(context, status);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withValues(alpha: isDark ? 0.25 : 0.12)
                                      : (isDark ? theme.colorScheme.surfaceContainerHighest : Colors.grey.shade100),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? color : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getStatusIcon(status),
                                        color: color,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _getStatusText(status),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? color : theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: color,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // Поле ввода причины отказа
                            if (isDeclinedStatus && currentStatus == OrderStatus.declined) ...[
                              const SizedBox(height: 8),
                              TextField(
                                controller: reasonController,
                                maxLines: 2,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Укажите причину отказа...',
                                  filled: true,
                                  fillColor: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: reasonController.text.trim().isEmpty
                                      ? null
                                      : () {
                                          final reason = reasonController.text.trim();
                                          context.read<ManageOrdersBloc>().add(
                                                UpdateStatusEvent(
                                                  docId: id,
                                                  statusType: statusType,
                                                  status: OrderStatus.declined,
                                                  reason: reason,
                                                ),
                                              );
                                          Navigator.pop(context, OrderStatus.declined);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Подтвердить отказ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

// Вспомогательные функции для цвета, иконки и названия
Color _getStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.accepted:
      return Colors.green;
    case OrderStatus.declined:
      return Colors.red;
    case OrderStatus.waiting:
      return Colors.amber;
  }
}

IconData _getStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.accepted:
      return Icons.check_circle_outline;
    case OrderStatus.declined:
      return Icons.cancel_outlined;
    case OrderStatus.waiting:
      return Icons.access_time;
  }
}

String _getStatusText(OrderStatus status) {
  switch (status) {
    case OrderStatus.accepted:
      return 'Accepted';
    case OrderStatus.declined:
      return 'Declined';
    case OrderStatus.waiting:
      return 'Waiting';
  }
}
