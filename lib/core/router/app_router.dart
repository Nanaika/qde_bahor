import 'package:go_router/go_router.dart';
import 'package:qde_eco_bahor/features/admin/presentation/discounts_page.dart';
import 'package:qde_eco_bahor/features/admin/presentation/manage_orders_page.dart';
import 'package:qde_eco_bahor/features/admin/presentation/add_product_page.dart';
import 'package:qde_eco_bahor/features/admin/presentation/add_product_type_page.dart';
import 'package:qde_eco_bahor/features/admin/presentation/home_page_admin.dart';
import 'package:qde_eco_bahor/features/admin/presentation/moderate_users_page.dart';
import 'package:qde_eco_bahor/features/cart/presentation/cart_screen.dart';
import 'package:qde_eco_bahor/features/home/presentation/pages/home_page.dart';

import '../../features/admin/models/product_model.dart';
import '../../features/admin/presentation/manage_products_page.dart';
import '../../features/admin/presentation/restricted_products_page.dart';
import '../../features/client/presentation/client_home_page.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/client_home',
        name: 'client_home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/restricted_products/:userId',
        name: 'restrictedProducts',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';

          return RestrictedProductsPage(
            userId: userId,
          );
        },
      ),
      GoRoute(
        path: '/user_discounts/:userId',
        name: 'user_discounts',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';

          return DiscountsPage(
            userId: userId,
          );
        },
      ),
      GoRoute(
        path: '/moderate_users',
        name: 'moderate_users',
        builder: (context, state) => const ModerateUsersPage(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/manage_orders',
        name: 'manage_orders',
        builder: (context, state) => const ManageOrdersPage(),
      ),
      GoRoute(
        path: '/add_product',
        builder: (context, state) {
          // Извлекаем объект из extra (будет null при создании)
          final product = state.extra as ProductModel?;

          return AddProductPage(product: product);
        },
      ),
      GoRoute(
        path: '/add_product_type',
        name: 'add_product_type',
        builder: (context, state) => const AddProductTypePage(),
      ),
      GoRoute(
        path: '/admin_home',
        name: 'admin_home',
        builder: (context, state) => const HomePageAdmin(),
      ),
      GoRoute(
        path: '/manage_products',
        name: 'manage_products',
        builder: (context, state) => const ManageProductsPage(),
      ),
    ],
  );
}
