import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/features/admin/moderate_order/order_model.dart';
import 'package:qde_eco_bahor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_eco_bahor/features/auth/presentation/bloc/auth_state.dart';

import '../../admin/discount/discount_model.dart';
import '../../client/presentation/client_home_page.dart';
import '../cart_bloc.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final List<DiscountModel> discounts;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticatedState) {
      discounts = authState.user.discounts;
    } else {
      discounts = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => context.read<CartCubit>().clearCart(),
          ),
        ],
      ),
      body: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state.status == CartStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Your order has been placed!')),
            );
          } else if (state.status == CartStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.errorMessage}')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CartStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.items.isEmpty) {
            return const Center(
              child: Text('Cart is empty'),
            );
          }

          // Расчет итоговой суммы со скидкой
          double totalPriceWithDiscount = 0;
          for (final item in state.items) {
            final basePrice = item.variant.price ?? 0;

            final discount = discounts.firstWhereOrNull(
              (d) => d.productId == item.product.id && d.variantId == item.variant.id,
            );

            final discountPercent = discount?.discountPercent ?? 0;
            final finalPrice = discountPercent > 0 ? basePrice * (1 - discountPercent / 100) : basePrice;

            totalPriceWithDiscount += finalPrice * item.quantity;
          }

          final hasDiscount = totalPriceWithDiscount < state.totalAmount;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];

                    // Расчет скидки для конкретного элемента списка
                    final basePrice = item.variant.price ?? 0;
                    final itemDiscount = discounts.firstWhereOrNull(
                      (d) => d.productId == item.product.id && d.variantId == item.variant.id,
                    );
                    final discountPercent = itemDiscount?.discountPercent ?? 0;
                    final finalUnitPrice = discountPercent > 0 ? basePrice * (1 - discountPercent / 100) : basePrice;
                    final itemTotalPriceWithDiscount = finalUnitPrice * item.quantity;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Изображение
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: item.product.photoUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.product.photoUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.image),
                            ),
                            const SizedBox(width: 12),

                            // Описание и цена
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Variant: ${item.variant.name}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (discountPercent > 0) ...[
                                    Text(
                                      '${formatNumber(item.totalPrice)} sum',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                  Text(
                                    '${formatNumber(itemTotalPriceWithDiscount)} sum',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Счетчики
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () => context.read<CartCubit>().updateQuantity(item.variant.id, -1),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () => context.read<CartCubit>().updateQuantity(item.variant.id, 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Нижняя панель оформления
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Total (${state.totalCount} pc):',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 2),
                              if (hasDiscount) ...[
                                Text(
                                  '${formatNumber(state.totalAmount)} sum',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                              Text(
                                '${formatNumber(totalPriceWithDiscount)} sum',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7000FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              final authState = context.read<AuthBloc>().state as AuthAuthenticatedState;
                              final user = authState.user;
                              final order = OrderModel(
                                id: '',
                                items: state.items,
                                totalPrice: state.totalAmount,
                                owner: user,
                                totalDiscountPrice: totalPriceWithDiscount,
                              );
                              context.read<CartCubit>().addOrder(order);
                            },
                            child: const Text(
                              'Checkout',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
