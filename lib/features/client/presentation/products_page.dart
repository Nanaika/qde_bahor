// 1. Страница каталога товаров
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../../admin/manage_products/manage_products_bloc.dart';
import '../../admin/manage_products/manage_products_event.dart';
import '../../admin/manage_products/manage_products_state.dart';
import '../../admin/manage_products/product_types_bloc.dart';
import '../../admin/models/product_type_model.dart';
import 'client_home_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final List<ProductTypeModel> _types;

  final Map<String, TextEditingController> _searchControllers = {};

  @override
  void initState() {
    super.initState();
    context.read<ManageProductsBloc>().add(GetProductsEvent());

    final state = getIt<ProductTypesBloc>().state;
    if (state is ManageProductsTypeSuccess) {
      _types = state.types;
    } else {
      _types = [];
    }

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
    final currentCategory = _types.isNotEmpty ? _types[_tabController.index] : null;
    final activeSearchController =
        currentCategory != null ? _searchControllers[currentCategory.id]! : TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      // backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/cart');
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
        title: Text(
          'Products'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (currentCategory != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: TextField(
                controller: activeSearchController,
                decoration: InputDecoration(
                  hintText: 'search_in'.tr(args: [currentCategory.getName(currentLang)]),
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: activeSearchController,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => activeSearchController.clear(),
                      );
                    },
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (_types.isNotEmpty)
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              // labelColor: theme.primaryColor,
              unselectedLabelColor: Colors.grey.shade600.withValues(alpha: 0.5),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              indicatorColor: theme.primaryColor,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: _types.map((cat) {
                return Tab(text: cat.getName(currentLang));
              }).toList(),
            ),
          // Divider(height: 1, color: Colors.grey.shade200),
          Expanded(
            child: BlocBuilder<ManageProductsBloc, ManageProductsState>(
              builder: (context, state) {
                if (state is ManageProductsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ManageProductsSuccess) {
                  final allProducts = state.products;

                  return TabBarView(
                    controller: _tabController,
                    children: _types.map((category) {
                      final categoryProducts = allProducts.where((p) => p.productType.id == category.id).toList();

                      return CategoryProductGrid(
                        key: PageStorageKey('category_${category.id}'),
                        searchController: _searchControllers[category.id]!,
                        products: categoryProducts,
                      );
                    }).toList(),
                  );
                }

                if (state is ManageProductsError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        state.failure.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
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
