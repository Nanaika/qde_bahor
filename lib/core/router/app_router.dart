import 'package:go_router/go_router.dart';
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
    ],
  );
}
