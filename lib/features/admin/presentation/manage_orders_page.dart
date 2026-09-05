import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/features/admin/moderate_order/status_type.dart';

import '../moderate_order/manage_order_state.dart';
import '../moderate_order/manage_orders_bloc.dart';
import '../moderate_order/manage_orders_event.dart';
import '../moderate_order/order_model.dart';

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
        title: Text('Orders'.tr()),
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
              return Center(child: Text('No orders'.tr()));
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
    final netto = order.items.fold(0.0, (sum, item) {
      final buy = item.variant.buyQuantity ?? 0;
      final free = item.variant.freeQuantity ?? 0;
      final bonus = (buy > 0 && free > 0) ? (item.quantity ~/ buy) * free : 0;
      return sum + ((item.variant.netWeight ?? 0) * (item.quantity + bonus));
    });

    final brutto = order.items.fold(0.0, (sum, item) {
      final buy = item.variant.buyQuantity ?? 0;
      final free = item.variant.freeQuantity ?? 0;
      final bonus = (buy > 0 && free > 0) ? (item.quantity ~/ buy) * free : 0;
      return sum + ((item.variant.grossWeight ?? 0) * (item.quantity + bonus));
    });
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'order_number'.tr(args: [order.id.toString()]),
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
                  'User'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  order.owner.name,
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
                Text(
                  order.owner.company,
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
                Text(
                  order.owner.number,
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

                // Расчет бонусов для товара
                final buyQty = item.variant.buyQuantity ?? 0;
                final freeQty = item.variant.freeQuantity ?? 0;
                final itemBonus = (buyQty > 0 && freeQty > 0) ? (item.quantity ~/ buyQty) * freeQty : 0;
                final totalItemQty = item.quantity + itemBonus; // Общее количество с учетом бонусов

                // Вес НЕТТО и БРУТТО с учетом бонусов
                final double itemNetto =
                    double.parse(((item.variant.netWeight ?? 0) * totalItemQty).toStringAsFixed(1));
                final double itemBrutto =
                    double.parse(((item.variant.grossWeight ?? 0) * totalItemQty).toStringAsFixed(1));

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
                              'netto_brutto_summary'.tr(namedArgs: {
                                'netto': itemNetto.toString(),
                                'brutto': itemBrutto.toString(),
                              }),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(itemBonus > 0
                                    ? 'item_quantity_bonus'.tr(namedArgs: {
                                        'quantity': item.quantity.toString(),
                                        'bonus': itemBonus.toString(),
                                      })
                                    : 'item_quantity_normal'.tr(namedArgs: {
                                        'quantity': item.quantity.toString(),
                                      })),
                                const SizedBox(width: 12),
                                Text(
                                  'item_total_price'.tr(namedArgs: {
                                    'price': item.totalPrice.toString(),
                                  }),
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
                        child: Text(
                          'Total weight:'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                          'order_total_weights'.tr(namedArgs: {
                            'netto': netto.toStringAsFixed(2),
                            'brutto': brutto.toStringAsFixed(2),
                          }),
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
                  Text(
                    'Total:'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                          if (order.totalDiscountPrice > 0 && order.totalDiscountPrice < order.totalPrice) ...[
                            Text(
                              'order_total_price'.tr(namedArgs: {
                                'price': order.totalPrice.toString(),
                              }),
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.outline,
                                  decoration: TextDecoration.lineThrough),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            'order_final_price'.tr(namedArgs: {
                              'price': (order.totalDiscountPrice > 0 ? order.totalDiscountPrice : order.totalPrice)
                                  .toString(),
                            }),
                            style: const TextStyle(
                              fontSize: 18,
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
                  title: 'Select status'.tr(),
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
                    Text(
                      'Warehouse Status:'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                          Text('Declined reason:'.tr()),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(order.warehouseDeclinedMessage),
                          const SizedBox(
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
                  title: 'Select status'.tr(),
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
                    Text(
                      'Accounting Status:'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                          Text('Declined reason:'.tr()),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(order.accountingDeclinedMessage),
                          const SizedBox(
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
                showDriverStatusPickerBottomSheet(
                  context,
                  title: 'Select status'.tr(),
                  currentStatus: order.driverStatus,
                  id: order.id,
                  warehouseStatus: order.warehouseStatus,
                  accountingStatus: order.accountingStatus,
                );
              },
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver Status:'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    buildDriverStatusRow(order.driverStatus),
                    const SizedBox(
                      height: 10,
                    ),
                    if (order.driverStatus == DriverStatus.shipped)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Driver number'.tr()),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(order.driverPhone),
                            const SizedBox(
                              height: 10,
                            ),
                            Text('Details'.tr()),
                            const SizedBox(
                              height: 10,
                            ),
                            if (order.driverDescription.isNotEmpty) Text(order.driverDescription),
                          ],
                        ),
                      ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        DeleteOrderButton(
                          orderId: order.id,
                        ),
                      ],
                    )
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
  Color statusColor;
  Color statusTextColor;
  String statusText;

  switch (status) {
    case OrderStatus.accepted:
      statusColor = const Color(0xFFE8F5E9);
      statusTextColor = const Color(0xFF2E7D32);
      statusText = 'accepted'.tr();
      break;
    case OrderStatus.declined:
      statusColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFC62828);
      statusText = 'declined'.tr();
      break;
    case OrderStatus.waiting:
      statusColor = const Color(0xFFFFF8E1);
      statusTextColor = Colors.amber;
      statusText = 'waiting'.tr();
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

Widget buildDriverStatusRow(DriverStatus status) {
  Color statusColor;
  Color statusTextColor;
  String statusText;

  switch (status) {
    case DriverStatus.shipped:
      statusColor = const Color(0xFFE8F5E9);
      statusTextColor = const Color(0xFF2E7D32);
      statusText = 'shipped'.tr();
      break;
    case DriverStatus.collecting:
      statusColor = const Color(0xFFE3F2FD);
      statusTextColor = const Color(0xFF1565C0);
      statusText = 'collecting'.tr();
      break;
    case DriverStatus.waiting:
      statusColor = const Color(0xFFFFF8E1);
      statusTextColor = Colors.amber;
      statusText = 'waiting'.tr();
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                            if (isDeclinedStatus && currentStatus == OrderStatus.declined) ...[
                              const SizedBox(height: 8),
                              TextField(
                                controller: reasonController,
                                maxLines: 2,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Enter reason for decline...'.tr(),
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
                                  child: Text(
                                    'Confirm Decline'.tr(),
                                    style: const TextStyle(color: Colors.white),
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
      return 'accepted'.tr();
    case OrderStatus.declined:
      return 'declined'.tr();
    case OrderStatus.waiting:
      return 'waiting'.tr();
  }
}

enum DriverStatus {
  waiting, // Ожидание
  collecting, // Сбор
  shipped, // Отправлен
}

String getDriverStatusText(DriverStatus status) {
  switch (status) {
    case DriverStatus.waiting:
      return 'waiting'.tr();
    case DriverStatus.collecting:
      return 'collecting'.tr();
    case DriverStatus.shipped:
      return 'shipped'.tr();
  }
}

IconData getDriverStatusIcon(DriverStatus status) {
  switch (status) {
    case DriverStatus.waiting:
      return Icons.hourglass_empty;
    case DriverStatus.collecting:
      return Icons.inventory_2_outlined;
    case DriverStatus.shipped:
      return Icons.local_shipping_outlined;
  }
}

Color getDriverStatusColor(DriverStatus status) {
  switch (status) {
    case DriverStatus.waiting:
      return Colors.amber;
    case DriverStatus.collecting:
      return Colors.blue;
    case DriverStatus.shipped:
      return Colors.green;
  }
}

Future<DriverStatus?> showDriverStatusPickerBottomSheet(
  BuildContext context, {
  required String title,
  required DriverStatus currentStatus,
  required OrderStatus warehouseStatus,
  required OrderStatus accountingStatus,
  required String id,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final bool isAllowedToChange = warehouseStatus == OrderStatus.accepted && accountingStatus == OrderStatus.accepted;

  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();

  return showModalBottomSheet<DriverStatus>(
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

                    if (!isAllowedToChange) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade900.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Status update is unavailable until Warehouse and Accounting approve the order.'.tr(),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Список статусов
                    ...DriverStatus.values.map((status) {
                      final isSelected = status == currentStatus;
                      final color = getDriverStatusColor(status);
                      final isShippedStatus = status == DriverStatus.shipped;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: !isAllowedToChange
                                  ? null
                                  : () {
                                      if (isShippedStatus) {
                                        setState(() {
                                          currentStatus = DriverStatus.shipped;
                                        });
                                      } else {
                                        context.read<ManageOrdersBloc>().add(
                                              UpdateDriverStatusEvent(
                                                docId: id,
                                                status: status,
                                              ),
                                            );
                                        Navigator.pop(context, status);
                                      }
                                    },
                              child: Opacity(
                                opacity: isAllowedToChange ? 1.0 : 0.5,
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
                                          getDriverStatusIcon(status),
                                          color: color,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          getDriverStatusText(status),
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
                            ),
                            if (isShippedStatus && currentStatus == DriverStatus.shipped && isAllowedToChange) ...[
                              const SizedBox(height: 12),

                              TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Driver\'s phone number'.tr(),
                                  prefixIcon: const Icon(Icons.phone),
                                  filled: true,
                                  fillColor: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Описание / Комментарий
                              TextField(
                                controller: descriptionController,
                                maxLines: 2,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Description (delivery details)'.tr(),
                                  prefixIcon: const Icon(Icons.notes),
                                  filled: true,
                                  fillColor: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Кнопка подтверждения
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      (phoneController.text.trim().isEmpty || descriptionController.text.trim().isEmpty)
                                          ? null
                                          : () {
                                              context.read<ManageOrdersBloc>().add(
                                                    UpdateDriverStatusEvent(
                                                      docId: id,
                                                      status: DriverStatus.shipped,
                                                      driverPhone: phoneController.text.trim(),
                                                      driverDescription: descriptionController.text.trim(),
                                                    ),
                                                  );
                                              Navigator.pop(context, DriverStatus.shipped);
                                            },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Confirm Delivery'.tr(),
                                    style: const TextStyle(color: Colors.white),
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

class DeleteOrderButton extends StatelessWidget {
  final String orderId;

  const DeleteOrderButton({
    super.key,
    required this.orderId,
  });

  void _showDeleteDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text('Delete Order'.tr()),
          content: Text(
            'Are you sure you want to delete this order? This action cannot be undone.'.tr(),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'.tr()),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                context.read<ManageOrdersBloc>().add(DeleteOrderEvent(orderId));
                Navigator.pop(dialogContext);
              },
              child: Text('Delete'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: () => _showDeleteDialog(context),
      style: IconButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red,
      ),
      icon: const Icon(Icons.delete, size: 20),
    );
  }
}
