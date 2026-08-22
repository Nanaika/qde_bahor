import 'package:go_router/go_router.dart';
import 'package:qde_eco_bahor/features/auth/presentation/pages/login_page.dart';
import 'package:qde_eco_bahor/features/counter/presentation/pages/counter_page.dart';
import 'package:qde_eco_bahor/features/example_feature/presentation/pages/example_page.dart';
import 'package:qde_eco_bahor/features/home/presentation/pages/home_page.dart';

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
        path: '/example',
        name: 'example',
        builder: (context, state) => const ExamplePage(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/counter',
        name: 'counter',
        builder: (context, state) => const CounterPage(),
      ),
    ],
  );
}
