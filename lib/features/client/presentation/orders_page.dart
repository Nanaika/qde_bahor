import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/core/utils/format_numbers.dart';
import 'package:qde_eco_bahor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_eco_bahor/features/auth/presentation/bloc/auth_state.dart';

import '../../admin/moderate_order/order_model.dart';
import '../../admin/presentation/manage_orders_page.dart';
import '../orders/orders_bloc.dart';
import '../orders/orders_event.dart';
import '../orders/orders_state.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      userId = authState.user.id;
    } else {
      userId = null;
    }

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Text('User is no authorized'.tr()),
        ),
      );
    }

    return BlocProvider(
      create: (context) => ClientOrdersBloc()..add(SubscribeToClientOrdersEvent(userId!)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Orders'.tr(context: context), style: const TextStyle(fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: BlocBuilder<ClientOrdersBloc, ClientOrdersState>(
          builder: (context, state) {
            if (state is ClientOrdersLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ClientOrdersError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              );
            }

            if (state is ClientOrdersSuccess) {
              if (state.orders.isEmpty) {
                return Center(
                  child: Text(
                    'You do not have any orders yet'.tr(),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return _OrderItemTile(order: order);
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

class _OrderItemTile extends StatelessWidget {
  final OrderModel order;

  const _OrderItemTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Расчет брутто и нетто с учетом бонусов
    double totalGross = 0.0;
    double totalNet = 0.0;

    // Собираем строки названий продуктов с их количеством и бонусами
    final productNamesList = <String>[];

    for (final item in order.items) {
      final buyQty = item.variant.buyQuantity ?? 0;
      final freeQty = item.variant.freeQuantity ?? 0;
      final itemBonus = (buyQty > 0 && freeQty > 0) ? (item.quantity ~/ buyQty) * freeQty : 0;
      final totalItemQty = item.quantity + itemBonus;

      // Вес считает общее количество (оплаченные + бонусные)
      totalGross += item.variant.grossWeight * totalItemQty;
      totalNet += item.variant.netWeight * totalItemQty;

      // Текст названия товара с бонусом
      if (itemBonus > 0) {
        productNamesList.add(
            '${item.product.name}\n(${item.variant.name}) x ${formatCountNumber(item.quantity)} + ${formatCountNumber(itemBonus)} free');
      } else {
        productNamesList.add('${item.product.name}\n(${item.variant.name}) x${formatCountNumber(item.quantity)}');
      }
    }

    final finalPrice = order.totalDiscountPrice > 0 ? order.totalDiscountPrice : order.totalPrice;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Номер заказа
            // Text(
            //   'order_number_title'.tr(namedArgs: {
            //     'id': order.id.toString(),
            //   }),
            //   style: theme.textTheme.titleMedium?.copyWith(
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),

            // 2. Список заказанных товаров
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Products: '.tr(),
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: productNamesList.isEmpty
                        ? [
                            Text(
                              'No products'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ]
                        : productNamesList.map((name) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),

            // 3. Вес (Брутто / Нетто)
            Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Weight (Gross / Net)'.tr(),
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${formatWeightNumber(totalGross)} кг / ${formatWeightNumber(totalNet)} кг',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 4. Информация о количестве (Оплачено / Бонусы / Всего)
            Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Quantity (Paid + Bonus)'.tr(),
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    order.totalBonusCount > 0
                        ? 'order_quantity_details'.tr(namedArgs: {
                            'paidCount': formatCountNumber(order.totalPaidCount).toString(),
                            'bonusCount': formatCountNumber(order.totalBonusCount).toString(),
                            'totalCount': formatCountNumber(order.totalQuantityCount).toString(),
                          })
                        : 'order_quantity_single'.tr(namedArgs: {
                            'paidCount': formatCountNumber(order.totalPaidCount).toString(),
                          }),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 5. Общая сумма

            Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Total'.tr(),
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (order.totalDiscountPrice > 0 && order.totalDiscountPrice < order.totalPrice) ...[
                        Text(
                          'order_total_price_sum'.tr(namedArgs: {
                            'price': formatNumber(order.totalPrice).toString(),
                          }),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        'order_final_price_sum'.tr(namedArgs: {
                          'price': formatNumber(finalPrice).toString(),
                        }),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 6. Чипы статусов и доп. инфы в Wrap
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Склад
                _buildStatusChipByEnum(
                  context,
                  label: 'warehouse_status'.tr(args: [order.warehouseStatus.name.tr()]),
                  status: order.warehouseStatus,
                ),

                // Бухгалтерия
                _buildStatusChipByEnum(
                  context,
                  label: 'accounting_status'.tr(args: [order.accountingStatus.name.tr()]),
                  status: order.accountingStatus,
                ),

                // Водитель (DriverStatus)
                _buildDriverStatusChip(
                  context,
                  label: 'driver_status'.tr(args: [order.driverStatus.name.tr()]),
                  status: order.driverStatus,
                ),

                // Телефон водителя (Синий)
                if (order.driverPhone.isNotEmpty)
                  _buildBlueChip(
                    context,
                    label: order.driverPhone,
                    icon: Icons.phone_outlined,
                  ),

                // Инфо от водителя (Синий)
                if (order.driverDescription.isNotEmpty)
                  _buildBlueChip(
                    context,
                    label: 'driver_info'.tr(args: [order.driverDescription]),
                  ),

                // Отказ склада (Красный)
                if (order.warehouseDeclinedMessage.isNotEmpty)
                  _buildColoredChip(
                    context,
                    label: 'warehouse_refusal'.tr(args: [order.warehouseDeclinedMessage]),
                    bgColor: const Color(0xFFFFDAD6),
                    textColor: const Color(0xFF410002),
                  ),

                // Отказ бухгалтерии (Красный)
                if (order.accountingDeclinedMessage.isNotEmpty)
                  _buildColoredChip(
                    context,
                    label: 'accounting_rejected'.tr(args: [order.accountingDeclinedMessage]),
                    bgColor: const Color(0xFFFFDAD6),
                    textColor: const Color(0xFF410002),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Чип для OrderStatus (Склад, Бухгалтерия)
  Widget _buildStatusChipByEnum(BuildContext context, {required String label, required OrderStatus status}) {
    if (status == OrderStatus.declined) {
      // Красный
      return _buildColoredChip(context,
          label: label, bgColor: const Color(0xFFFFDAD6), textColor: const Color(0xFF410002));
    } else if (status == OrderStatus.accepted) {
      // Зеленый
      return _buildColoredChip(context,
          label: label, bgColor: const Color(0xFFD7EFD0), textColor: const Color(0xFF072100));
    } else if (status == OrderStatus.waiting) {
      // Желтый
      return _buildColoredChip(context,
          label: label, bgColor: const Color(0xFFFFE088), textColor: const Color(0xFF261900));
    }
    // Остальное - Синий
    return _buildBlueChip(context, label: label);
  }

  // Чип для DriverStatus
  Widget _buildDriverStatusChip(BuildContext context, {required String label, required DriverStatus status}) {
    switch (status) {
      case DriverStatus.waiting:
        // Желтый (Ожидание)
        return _buildColoredChip(
          context,
          label: label,
          bgColor: const Color(0xFFFFE088),
          textColor: const Color(0xFF261900),
        );
      case DriverStatus.collecting:
        // Синий (Сбор)
        return _buildBlueChip(context, label: label);
      case DriverStatus.shipped:
        // Зеленый (Отправлен / В пути)
        return _buildColoredChip(
          context,
          label: label,
          bgColor: const Color(0xFFD7EFD0),
          textColor: const Color(0xFF072100),
        );
    }
  }

  // Дефолтный синий чип
  Widget _buildBlueChip(BuildContext context, {required String label, IconData? icon}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: theme.colorScheme.onSecondaryContainer),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  // Кастомный цветной чип
  Widget _buildColoredChip(BuildContext context,
      {required String label, required Color bgColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
