import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_eco_bahor/core/di/injection_container.dart';
import 'package:qde_eco_bahor/features/admin/manage_products/manage_products_event.dart';
import 'package:qde_eco_bahor/features/admin/manage_products/product_types_bloc.dart';
import 'package:qde_eco_bahor/features/admin/models/product_model.dart';
import 'package:qde_eco_bahor/features/cart/cart_bloc.dart';

import '../../admin/manage_products/manage_products_bloc.dart';
import '../../admin/manage_products/manage_products_state.dart';
import '../../admin/models/product_type_model.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final List<ProductTypeModel> _types;

  // Храним отдельные TextEditingController для каждой категории,
  // чтобы текст поиска НЕ сбрасывался при переключении табов
  final Map<String, TextEditingController> _searchControllers = {};

  @override
  void initState() {
    super.initState();
    context.read<ManageProductsBloc>().add(GetProductsEvent());
    // 1. Достаем стейт из заранее заиниченного блока
    final state = getIt<ProductTypesBloc>().state;
    if (state is ManageProductsError) {}
    // 2. Достаем типы из стейта (подставь имя своего Success-стейта и поля)
    if (state is ManageProductsTypeSuccess) {
      _types = state.types;
    } else {
      _types = [];
    }

    // 3. Инициализируем контроллеры на основе имеющихся типов
    _tabController = TabController(
      length: _types.length,
      vsync: this,
    );

    for (final type in _types) {
      _searchControllers[type.id] = TextEditingController();
    }

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _searchControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = Localizations.localeOf(context).languageCode;
    final currentCategory = _types[_tabController.index];
    final activeSearchController = _searchControllers[currentCategory.id]!;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                context.push('/cart');
              },
              icon: Icon(Icons.shopping_cart))
        ],
        title: Text('Каталог товаров'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Поле поиска (привязано к контроллеру текущей выбранной категории)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: activeSearchController,
              decoration: InputDecoration(
                hintText: 'Поиск в "${currentCategory.getName(currentLang)}"...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: activeSearchController,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => activeSearchController.clear(),
                    );
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // 2. Таб-бар категорий
          TabBar(
            controller: _tabController,
            isScrollable: true,
            // labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: _types.map((cat) {
              return Tab(text: cat.getName(currentLang));
            }).toList(),
          ),

          const Divider(height: 1),

          // 3. Списки товаров по табам
          Expanded(
            child: BlocBuilder<ManageProductsBloc, ManageProductsState>(
              builder: (context, state) {
                // 1. Показываем лоадер, если идет загрузка
                if (state is ManageProductsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Если списки загружены
                if (state is ManageProductsSuccess) {
                  final allProducts = state.products; // Твой список всех продуктов из стейта

                  return TabBarView(
                    controller: _tabController,
                    children: _types.map((category) {
                      // Фильтруем товары по текущей категории из BLoC-списка
                      final categoryProducts = allProducts.where((p) => p.productType.id == category.id).toList();

                      return CategoryProductList(
                        key: PageStorageKey('category_${category.id}'),
                        searchController: _searchControllers[category.id]!,
                        products: categoryProducts,
                      );
                    }).toList(),
                  );
                }

                // 3. Если ошибка или пустой стейт
                if (state is ManageProductsError) {
                  return Center(child: Text(state.failure.message));
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Виджет списка товаров конкретной категории.
/// Использует AutomaticKeepAliveClientMixin, чтобы НЕ пересоздавать список при смене таба.
class CategoryProductList extends StatefulWidget {
  final TextEditingController searchController;
  final List<ProductModel> products;

  const CategoryProductList({
    super.key,
    required this.searchController,
    required this.products,
  });

  @override
  State<CategoryProductList> createState() => _CategoryProductListState();
}

class _CategoryProductListState extends State<CategoryProductList> with AutomaticKeepAliveClientMixin {
  // Гарантирует сохранение состояния таба (не пересоздается и не теряет фильтрацию)
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Подписываемся на изменения поискового запроса этой категории
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {}); // Обновляем фильтрацию при вводе текста
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Обязательный вызов для KeepAlive

    final query = widget.searchController.text.toLowerCase().trim();

    // Фильтрация товаров по поисковому запросу текущей категории
    final filteredProducts = widget.products.where((product) {
      if (query.isEmpty) return true;
      return product.name.toLowerCase().contains(query) || product.description.toLowerCase().contains(query);
    }).toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text('Ничего не найдено', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showProductBottomSheet(context, product);
            },
          ),
        );
      },
    );
  }
}

void showProductBottomSheet(BuildContext context, ProductModel product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProductDetailBottomSheet(product: product),
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
  // Храним количество выбранного товара по id варианта: { variantId: quantity }
  final Map<String, int> _selectedQuantities = {};

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Считаем общую сумму всех выбранных вариантов
    double totalPrice = 0;
    int totalCount = 0;

    for (var variant in product.variants) {
      final qty = _selectedQuantities[variant.id] ?? 0;
      totalPrice += (variant.price ?? 0) * qty;
      totalCount += qty;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              // color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Заголовок и фото
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                if (product.photoUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.photoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                const SizedBox(width: 12),
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

          const Divider(height: 24),

          // Список всех вариантов с их ценами
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: product.variants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final variant = product.variants[index];
                final count = _selectedQuantities[variant.id] ?? 0;
                final variantPrice = variant.price ?? 0;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Название варианта и его цена
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              variant.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$variantPrice сум',
                              style: TextStyle(
                                fontSize: 14,
                                // color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Кнопки - / + и количество
                      Container(
                        decoration: BoxDecoration(
                          // color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: count > 0
                                  ? () {
                                      setState(() {
                                        _selectedQuantities[variant.id] = count - 1;
                                      });
                                    }
                                  : null,
                            ),
                            Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () {
                                setState(() {
                                  _selectedQuantities[variant.id] = count + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Нижняя панель с общей суммой заказа и кнопкой добавления
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: bottomPadding + 12,
            ),
            decoration: BoxDecoration(
              // color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Итоговая сумма
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Выбрано: $totalCount шт',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '$totalPrice сум',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Кнопка сохранения/добавления
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7000FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: totalCount > 0
                          ? () {
                              final cartCubit = context.read<CartCubit>();

                              // Проходим по всем выбранным вариантам
                              _selectedQuantities.forEach((variantId, qty) {
                                if (qty > 0) {
                                  // Находим модель варианта по его id
                                  final variant = product.variants.firstWhere(
                                    (v) => v.id == variantId,
                                  );

                                  // Добавляем вариант с его количеством в корзину
                                  cartCubit.addProduct(product, variant, qty);
                                }
                              });

                              // Закрываем BottomSheet
                              Navigator.pop(context);
                            }
                          : null,
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
