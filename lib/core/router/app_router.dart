import 'package:go_router/go_router.dart';
import 'package:qde_eco_bahor/features/admin/presentation/add_product_page.dart';
import 'package:qde_eco_bahor/features/admin/presentation/add_product_type_page.dart';
import 'package:qde_eco_bahor/features/admin/presentation/home_page_admin.dart';
import 'package:qde_eco_bahor/features/home/presentation/pages/home_page.dart';

import '../../features/admin/presentation/manage_products_page.dart';

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
        path: '/add_product',
        name: 'add_product',
        builder: (context, state) => const AddProductPage(),
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
