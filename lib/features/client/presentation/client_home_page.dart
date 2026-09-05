import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/features/admin/discount/discount_model.dart';
import 'package:qde_eco_bahor/features/admin/models/product_model.dart';
import 'package:qde_eco_bahor/features/admin/restriction/restricted_product_model.dart';
import 'package:qde_eco_bahor/features/cart/cart_bloc.dart';
import 'package:qde_eco_bahor/features/client/presentation/products_page.dart';
import 'package:qde_eco_bahor/features/client/presentation/profile_page.dart';

import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import 'orders_page.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ProductsPage(),
    OrdersPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool isModerated = false;

        if (state is AuthAuthenticatedState) {
          isModerated = state.user.isModerated; // Поле модерации в твоей UserModel
        }

        // Если не модерирован — жестко держим на 3-й странице (ProfilePage)
        final activeIndex = isModerated ? _currentIndex : 2;

        return Scaffold(
          body: IndexedStack(
            index: activeIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: activeIndex,
            onTap: (index) {
              if (!isModerated && index != 2) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account confirmation required'.tr()),
                    duration: const Duration(seconds: 2),
                  ),
                );
                return;
              }

              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: Colors.grey.shade500.withValues(alpha: 0.5),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.grid_view_rounded,
                  color: !isModerated ? Colors.grey.shade300 : null,
                ),
                activeIcon: const Icon(Icons.grid_view_rounded),
                label: 'Products'.tr(),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.receipt_long_outlined,
                  color: !isModerated ? Colors.grey.shade300 : null,
                ),
                activeIcon: const Icon(Icons.receipt_long_rounded),
                label: 'Orders'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline_rounded),
                activeIcon: const Icon(Icons.person_rounded),
                label: 'Profile'.tr(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryProductGrid extends StatefulWidget {
  final TextEditingController searchController;
  final List<ProductModel> products;

  const CategoryProductGrid({
    super.key,
    required this.searchController,
    required this.products,
  });

  @override
  State<CategoryProductGrid> createState() => _CategoryProductGridState();
}

class _CategoryProductGridState extends State<CategoryProductGrid> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final query = widget.searchController.text.toLowerCase().trim();

    final filteredProducts = widget.products.where((product) {
      if (query.isEmpty) return true;
      return product.name.toLowerCase().contains(query) || product.description.toLowerCase().contains(query);
    }).toList();

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Nothing found'.tr(),
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ProductGridCard(product: product);
      },
    );
  }
}

class ProductGridCard extends StatefulWidget {
  final ProductModel product;

  const ProductGridCard({super.key, required this.product});

  @override
  State<ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<ProductGridCard> {
  late final List<RestrictedProductModel> restricted;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      restricted = authState.user.restricted;
    } else {
      restricted = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isRestricted = restricted.any(
      (item) => item.productId == widget.product.id,
    );

    // Проверка наличия акции (купи N, получи M)
    final hasPromo = widget.product.variants.any(
      (v) => (v.buyQuantity ?? 0) > 0 && (v.freeQuantity ?? 0) > 0,
    );

    double minPrice = 0;
    if (widget.product.variants.isNotEmpty) {
      final prices = widget.product.variants.map((v) => v.price ?? 0.0).where((p) => p > 0).toList();
      if (prices.isNotEmpty) {
        minPrice = prices.reduce((a, b) => a < b ? a : b);
      }
    }

    final variantsCount = widget.product.variants.length;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isRestricted ? Colors.red.shade200 : Colors.grey.shade200.withValues(alpha: 0.5),
        ),
      ),
      child: Stack(
        children: [
          // 1. Основной контент (при неликвиде — полупрозрачный)
          Opacity(
            opacity: isRestricted ? 0.45 : 1.0,
            child: InkWell(
              onTap: isRestricted ? null : () => showProductBottomSheet(context, widget.product),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        widget.product.photoUrl.isNotEmpty
                            ? Image.network(
                                widget.product.photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 32),
                                ),
                              )
                            : Container(
                                color: Colors.grey.shade100,
                                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 32),
                              ),

                        // Варианты (Слева вверху)
                        if (variantsCount > 0)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'variants_count_label'.tr(namedArgs: {
                                  'count': variantsCount.toString(),
                                }),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                        // Бейдж АКЦИИ (Справа вверху)
                        if (hasPromo)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.shade600,
                                    Colors.deepOrange.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.shade900.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_offer_rounded,
                                    color: Colors.white,
                                    size: 11,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'BONUS'.tr(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1.2,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (widget.product.description.isNotEmpty)
                            Expanded(
                              child: Text(
                                widget.product.description,
                                style: const TextStyle(
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            const Spacer(),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (minPrice > 0) ...[
                                      Text(
                                        'from'.tr(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        'min_price_formatted'.tr(namedArgs: {
                                          'price': minPrice.toStringAsFixed(0),
                                        }),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ] else
                                      Text(
                                        'Out of stock'.tr(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade400,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 18,
                                  color: theme.primaryColor,
                                ),
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
          ),

          // 2. Блокирующий слой + акцентная плашка ровно по центру
          if (isRestricted) ...[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Container(
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade900.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.remove_circle_outline_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Not delivered to your region'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

void showProductBottomSheet(BuildContext context, ProductModel product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProductDetailBottomSheet(
      product: product,
    ),
  );
}

class ProductDetailBottomSheet extends StatefulWidget {
  final ProductModel product;

  const ProductDetailBottomSheet({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailBottomSheet> createState() => _ProductDetailBottomSheetState();
}

class _ProductDetailBottomSheetState extends State<ProductDetailBottomSheet> {
  late final List<DiscountModel> discounts;
  final Map<String, int> _selectedQuantities = {};

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
    final product = widget.product;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final theme = Theme.of(context);

    double totalPrice = 0;
    int totalCount = 0;
    int totalBonusCount = 0; // Добавлено для бонусов
    double totalPriceWithDiscount = 0;

    for (var variant in product.variants) {
      final qty = _selectedQuantities[variant.id] ?? 0;
      if (qty == 0) continue;

      final basePrice = variant.price ?? 0;

      totalPrice += basePrice * qty;
      totalCount += qty;

      // Расчет бонусов по варианту
      final buyQty = variant.buyQuantity ?? 0;
      final freeQty = variant.freeQuantity ?? 0;
      if (buyQty > 0 && freeQty > 0) {
        totalBonusCount += (qty ~/ buyQty) * freeQty;
      }

      final discount = discounts.where((d) => d.productId == product.id && d.variantId == variant.id).firstOrNull;

      final discountPercent = discount?.discountPercent ?? 0;
      final finalPrice = discountPercent > 0 ? basePrice * (1 - discountPercent / 100) : basePrice;

      totalPriceWithDiscount += finalPrice * qty;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.photoUrl.isNotEmpty
                      ? Image.network(
                          product.photoUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Divider(height: 0.5),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: product.variants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final variant = product.variants[index];
                final count = _selectedQuantities[variant.id] ?? 0;
                final variantPrice = variant.price ?? 0;
                final isSelected = count > 0;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              variant.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'variant_price_sum'.tr(namedArgs: {
                                'price': variantPrice.toString(),
                              }),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if ((variant.buyQuantity ?? 0) > 0 && (variant.freeQuantity ?? 0) > 0) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.card_giftcard_rounded,
                                      size: 13,
                                      color: Colors.orange.shade800,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'variant_promo_offer'.tr(namedArgs: {
                                          'buyQty': variant.buyQuantity.toString(),
                                          'freeQty': variant.freeQuantity.toString(),
                                        }),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _QuantityCounter(
                        count: count,
                        isSelected: isSelected,
                        onChanged: (newQty) {
                          setState(() {
                            _selectedQuantities[variant.id] = newQty;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 14,
              bottom: bottomPadding + 14,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                'selected_items_count'.tr(namedArgs: {
                                  'count': totalCount.toString(),
                                }),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              if (totalBonusCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'total_bonus_count_bonus'.tr(namedArgs: {
                                      'bonus': totalBonusCount.toString(),
                                    }),
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
                          const SizedBox(height: 2),
                          Text(
                            'total_price_formatted'.tr(namedArgs: {
                              'price': formatNumber(totalPrice),
                            }),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            'total_price_with_discount_formatted'.tr(namedArgs: {
                              'price': formatNumber(totalPriceWithDiscount),
                            }),
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
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7000FF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: totalCount > 0
                            ? () {
                                final cartCubit = context.read<CartCubit>();

                                _selectedQuantities.forEach((variantId, qty) {
                                  if (qty > 0) {
                                    final variant = product.variants.firstWhere(
                                      (v) => v.id == variantId,
                                    );

                                    // Считаем бонус индивидуально для текущего варианта:
                                    final buyQty = variant.buyQuantity ?? 0;
                                    final freeQty = variant.freeQuantity ?? 0;

                                    int variantBonus = 0;
                                    if (buyQty > 0 && freeQty > 0) {
                                      variantBonus = (qty ~/ buyQty) * freeQty;
                                    }

                                    cartCubit.addProduct(product, variant, qty, variantBonus);
                                  }
                                });

                                Navigator.pop(context);
                              }
                            : null,
                        child: Text(
                          'Add to Cart'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
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
      ),
    );
  }
}

class _QuantityCounter extends StatefulWidget {
  final int count;
  final bool isSelected;
  final ValueChanged<int> onChanged;

  const _QuantityCounter({
    required this.count,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  State<_QuantityCounter> createState() => _QuantityCounterState();
}

class _QuantityCounterState extends State<_QuantityCounter> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.count}');
  }

  @override
  void didUpdateWidget(covariant _QuantityCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    final parsed = int.tryParse(_controller.text) ?? 0;
    if (parsed != widget.count) {
      _controller.text = '${widget.count}';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateCount(int newCount) {
    final clamped = newCount.clamp(0, 1000000);
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.remove,
              size: 18,
              color: widget.count > 0 ? theme.colorScheme.onSurface : theme.disabledColor,
            ),
            onPressed: widget.count > 0 ? () => _updateCount(widget.count - 1) : null,
          ),
          SizedBox(
            width: 64, // Запас под 7 цифр (1 000 000)
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: widget.isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
              decoration: const InputDecoration.collapsed(
                hintText: '0',
              ).copyWith(
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                final parsed = int.tryParse(value) ?? 0;
                _updateCount(parsed);
              },
            ),
          ),
          IconButton(
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.add,
              size: 18,
              color: widget.count < 1000000 ? theme.colorScheme.onSurface : theme.disabledColor,
            ),
            onPressed: widget.count < 1000000 ? () => _updateCount(widget.count + 1) : null,
          ),
        ],
      ),
    );
  }
}

String formatNumber(num number) {
  // Округляем до 1 знака после запятой
  final formatted = number.toStringAsFixed(1);
  final parts = formatted.split('.');

  // Форматируем целую часть пробелами
  parts[0] = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]} ',
  );

  // Если дробная часть '.0', убираем её
  if (parts.length > 1 && parts[1] == '0') {
    return parts[0];
  }

  return parts.join('.');
}
