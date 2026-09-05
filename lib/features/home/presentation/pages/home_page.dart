import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/features/home/presentation/pages/role_gates.dart';

import '../../../../core/theme/theme_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Старт авторизации при запуске страницы
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoadingState || state is AuthInitialState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AuthErrorState) {
            return Center(
              child: Text(
                'Auth error: ${state.failure}',
                style: ThemeTextStyles.bodyLarge(context),
              ),
            );
          }
          return const RoleGateScreen();
          // return SingleChildScrollView(
          //   padding: EdgeInsets.all(ThemeDimensions.paddingL),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       Text(
          //         TelegramService.userId != null ? TelegramService.userId.toString() : '123456789',
          //         style: ThemeTextStyles.bodyLarge(context),
          //         textAlign: TextAlign.center,
          //       ),
          //       Text(
          //         TelegramService.firstName ?? 'Test name',
          //         style: ThemeTextStyles.bodyLarge(context),
          //         textAlign: TextAlign.center,
          //       ),
          //       Text(
          //         TelegramService.username ?? 'testUserName',
          //         style: ThemeTextStyles.bodyLarge(context),
          //         textAlign: TextAlign.center,
          //       ),
          //       ElevatedButton(
          //           onPressed: () {
          //             context.push('/admin_home');
          //           },
          //           child: Text('Admin')),
          //       ElevatedButton(
          //           onPressed: () {
          //             context.push('/client_home');
          //           },
          //           child: Text('Client')),
          //     ],
          //   ),
          // );
        },
      ),
    );
  }
}
