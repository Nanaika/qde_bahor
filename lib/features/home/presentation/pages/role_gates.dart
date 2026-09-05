import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/features/admin/presentation/home_page_admin.dart';

import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../client/presentation/client_home_page.dart';

class RoleGateScreen extends StatelessWidget {
  const RoleGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticatedState) {
      return const SizedBox.shrink();
    }

    final user = authState.user;

    final role = user.userType;

    switch (role) {
      case UserType.warehouse:
        return const HomePageAdmin();
      case UserType.accounting:
        return const HomePageAdmin();

      case UserType.client:
        return const MainNavigationScreen();
    }
  }
}
