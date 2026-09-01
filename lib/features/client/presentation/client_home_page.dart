import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/core/di/injection_container.dart';
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
                  const SnackBar(
                    content: Text('Account confirmation required'),
                    duration: Duration(seconds: 2),
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
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.receipt_long_outlined,
                  color: !isModerated ? Colors.grey.shade300 : null,
                ),
                activeIcon: const Icon(Icons.receipt_long_rounded),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
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
            const Text(
              'Nothing found',
              style: TextStyle(color: Colors.grey, fontSize: 15),
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
                        if (variantsCount > 0)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$variantsCount options',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
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
                                      const Text(
                                        'from',
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        '${minPrice.toStringAsFixed(0)} sum',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ] else
                                      Text(
                                        'Out of stock',
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
            // Поглощаем тапы, чтобы карточка гарантированно не нажималась
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {}, // Заглушка клика
                child: Container(
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Сама плашка
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.remove_circle_outline_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Not delivered to your region',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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

  final Map<String, int> _selectedQuantities = {};

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final theme = Theme.of(context);

    double totalPrice = 0;
    int totalCount = 0;

    double totalPriceWithDiscount = 0;

    for (var variant in product.variants) {
      final qty = _selectedQuantities[variant.id] ?? 0;
      if (qty == 0) continue;

      final basePrice = variant.price ?? 0;

      totalPrice += basePrice * qty;
      totalCount += qty;

      // Ищем скидку, если нет — получаем null
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
            child: Divider(
              height: 0.5,
            ),
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
                              '$variantPrice sum',
                              style: const TextStyle(
                                fontSize: 14,
                                // color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme
                              .surfaceContainerHighest, // На светлой — grey.shade100, на темной — темный серый
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.remove,
                                size: 18,
                                color: count > 0 ? theme.colorScheme.onSurface : theme.disabledColor,
                              ),
                              onPressed: count > 0
                                  ? () {
                                      setState(() {
                                        _selectedQuantities[variant.id] = count - 1;
                                      });
                                    }
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.add,
                                size: 18,
                                color: theme.colorScheme.onSurface,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedQuantities[variant.id] = count + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      )
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
              // color: Colors.white,
              // border: Border(top: BorderSide(color: Colors.grey.shade200.withValues(alpha: 0.25))),
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
                          Text(
                            'Selected: $totalCount pcs',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${formatNumber(totalPrice)} sum',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                                decoration: TextDecoration.lineThrough),
                          ),
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
                const SizedBox(
                  height: 6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7000FF),
                          // disabledBackgroundColor: Colors.grey.shade300,
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
                                    cartCubit.addProduct(product, variant, qty);
                                  }
                                });

                                Navigator.pop(context);
                              }
                            : null,
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
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
