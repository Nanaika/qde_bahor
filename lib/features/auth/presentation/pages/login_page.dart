import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_eco_bahor/core/theme/theme_dimensions.dart';
import 'package:qde_eco_bahor/core/widgets/error_widget.dart';
import 'package:qde_eco_bahor/core/widgets/language_toggle.dart';
import 'package:qde_eco_bahor/core/widgets/loading_widget.dart';
import 'package:qde_eco_bahor/core/widgets/theme_toggle.dart';
import 'package:qde_eco_bahor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_eco_bahor/features/auth/presentation/widgets/auth_form.dart';
import 'package:qde_eco_bahor/generated/locale_keys.g.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AuthBloc>(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: Text(LocaleKeys.auth_login.tr()),
          actions: const [
            LanguageToggle(),
            ThemeToggle(),
          ],
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            state.maybeWhen(
              authenticated: (user) {
                // После успешного входа возвращаемся на главную
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              orElse: () {},
            );
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return state.maybeWhen(
                initial: () => const SizedBox.shrink(),
                loading: () => LoadingWidget(message: LocaleKeys.common_loading.tr()),
                authenticated: (user) => _AuthenticatedView(user: user),
                unauthenticated: () => const AuthForm(),
                error: (failure) => ErrorDisplayWidget(
                  failure: failure,
                  onRetry: () {
                    context.read<AuthBloc>().add(const AuthEvent.checkAuthStatus());
                  },
                ),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthenticatedView extends StatelessWidget {
  final dynamic user;

  const _AuthenticatedView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(ThemeDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.auth_welcome.tr(namedArgs: {'name': user.name}),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEvent.logout());
              },
              icon: const Icon(Icons.logout),
              label: Text(LocaleKeys.auth_logout.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
