import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          isModerated = state.user.isModerated;
        }

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
