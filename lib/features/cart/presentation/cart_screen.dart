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

          // Расчет итоговой суммы со скидкой и независимый пересчет бонусов по вариантам
          double totalPriceWithDiscount = 0;
          int totalBonusCount = 0;
          int totalPaidCount = 0;

          for (final item in state.items) {
            final basePrice = item.variant.price ?? 0;

            final discount = discounts.firstWhereOrNull(
              (d) => d.productId == item.product.id && d.variantId == item.variant.id,
            );

            final discountPercent = discount?.discountPercent ?? 0;
            final finalPrice = discountPercent > 0 ? basePrice * (1 - discountPercent / 100) : basePrice;

            totalPriceWithDiscount += finalPrice * item.quantity;
            totalPaidCount += item.quantity;

            // Расчет бонусов по аналогии со шторкой
            final buyQty = item.variant.buyQuantity ?? 0;
            final freeQty = item.variant.freeQuantity ?? 0;
            if (buyQty > 0 && freeQty > 0) {
              totalBonusCount += (item.quantity ~/ buyQty) * freeQty;
            }
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

                    // Расчет скидки и бонусов для конкретного элемента
                    final basePrice = item.variant.price ?? 0;
                    final itemDiscount = discounts.firstWhereOrNull(
                      (d) => d.productId == item.product.id && d.variantId == item.variant.id,
                    );
                    final discountPercent = itemDiscount?.discountPercent ?? 0;
                    final finalUnitPrice = discountPercent > 0 ? basePrice * (1 - discountPercent / 100) : basePrice;
                    final itemTotalPriceWithDiscount = finalUnitPrice * item.quantity;

                    final buyQty = item.variant.buyQuantity ?? 0;
                    final freeQty = item.variant.freeQuantity ?? 0;
                    final itemBonusQuantity = (buyQty > 0 && freeQty > 0) ? (item.quantity ~/ buyQty) * freeQty : 0;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
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

                                      // Блок вывода количества: отображается ВСЕГДА
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: itemBonusQuantity > 0 ? Colors.orange.shade50 : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color:
                                                itemBonusQuantity > 0 ? Colors.orange.shade200 : Colors.grey.shade300,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          itemBonusQuantity > 0
                                              ? 'Qty: ${item.quantity} + $itemBonusQuantity free bonus'
                                              : 'Qty: ${item.quantity}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                itemBonusQuantity > 0 ? Colors.orange.shade900 : Colors.grey.shade800,
                                          ),
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

                                // Инпут с динамической шириной
                              ],
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _CartQuantityInput(
                                  quantity: item.quantity,
                                  onChanged: (newQty) {
                                    final delta = newQty - item.quantity;
                                    context.read<CartCubit>().updateQuantity(item.variant.id, delta);
                                  },
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
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.transparent, width: 0.8),
                                            ),
                                            child: Text(
                                              'Total: $totalPaidCount pc',
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                          ),
                                          if (totalBonusCount > 0) ...[
                                            const SizedBox(width: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.orange.shade200, width: 0.8),
                                              ),
                                              child: Text(
                                                '+ $totalBonusCount free',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange.shade900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
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
                                totalPaidCount: totalPaidCount,
                                totalBonusCount: totalBonusCount,
                                totalQuantityCount: totalPaidCount + totalBonusCount,
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

// Поле ввода количества товара с лимитом от 1 до 1,000,000
class _CartQuantityInput extends StatefulWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _CartQuantityInput({
    required this.quantity,
    required this.onChanged,
  });

  @override
  State<_CartQuantityInput> createState() => _CartQuantityInputState();
}

class _CartQuantityInputState extends State<_CartQuantityInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.quantity.toString());
  }

  @override
  void didUpdateWidget(covariant _CartQuantityInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      final currentTextVal = int.tryParse(_controller.text) ?? 0;
      if (currentTextVal != widget.quantity) {
        _controller.text = widget.quantity.toString();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String val) {
    setState(() {}); // Перерисовываем для обновления ширины поля

    if (val.isEmpty) return;

    final parsed = int.tryParse(val);
    if (parsed == null) return;

    if (parsed > 1000000) {
      _controller.text = '1000000';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      widget.onChanged(1000000);
      return;
    }

    if (parsed >= 1 && parsed != widget.quantity) {
      widget.onChanged(parsed);
    }
  }

  void _updateFromButtons(int value) {
    final clamped = value.clamp(1, 1000000);
    _controller.text = clamped.toString();
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    widget.onChanged(clamped);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Автоматический расчет ширины: базовые 24px + по 9px на каждую цифру
    final textLength = _controller.text.isEmpty ? 1 : _controller.text.length;
    final dynamicWidth = (24.0 + (textLength * 9.0)).clamp(36.0, 110.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          onPressed: widget.quantity > 1 ? () => _updateFromButtons(widget.quantity - 1) : null,
        ),
        SizedBox(
          width: dynamicWidth,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
            onChanged: _onTextChanged,
          ),
        ),
        IconButton(
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
          icon: const Icon(Icons.add_circle_outline, size: 20),
          onPressed: widget.quantity < 1000000 ? () => _updateFromButtons(widget.quantity + 1) : null,
        ),
      ],
    );
  }
}
