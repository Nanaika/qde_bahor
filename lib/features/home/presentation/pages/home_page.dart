import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_eco_bahor/core/theme/theme_border_styles.dart';
import 'package:qde_eco_bahor/core/theme/theme_colors.dart';
import 'package:qde_eco_bahor/core/theme/theme_dimensions.dart';
import 'package:qde_eco_bahor/core/theme/theme_text_styles.dart';
import 'package:qde_eco_bahor/core/widgets/language_toggle.dart';
import 'package:qde_eco_bahor/core/widgets/theme_toggle.dart';
import 'package:qde_eco_bahor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_eco_bahor/generated/locale_keys.g.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.home_title.tr()),
        actions: const [
          LanguageToggle(),
          ThemeToggle(),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ThemeDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: ThemeDimensions.spacingM),
            Text(
              LocaleKeys.home_welcome.tr(),
              style: ThemeTextStyles.headlineLarge(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeDimensions.spacingS),
            Text(
              LocaleKeys.home_description.tr(),
              style: ThemeTextStyles.bodyLarge(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeDimensions.spacingXL),
            // Модуль аутентификации
            _ModuleCard(
              title: LocaleKeys.home_auth_module.tr(),
              description: LocaleKeys.home_auth_module_desc.tr(),
              icon: Icons.login,
              color: Colors.blue,
              onTap: () => context.go('/auth'),
            ),
            SizedBox(height: ThemeDimensions.spacingM),
            // Модуль счетчика
            _ModuleCard(
              title: LocaleKeys.home_counter_module.tr(),
              description: LocaleKeys.home_counter_module_desc.tr(),
              icon: Icons.add_circle_outline,
              color: Colors.green,
              onTap: () => context.go('/counter'),
            ),
            SizedBox(height: ThemeDimensions.spacingM),
            // Пример модуль
            _ModuleCard(
              title: LocaleKeys.home_example_module.tr(),
              description: LocaleKeys.home_example_module_desc.tr(),
              icon: Icons.list,
              color: Colors.orange,
              onTap: () => context.go('/example'),
            ),
            SizedBox(height: ThemeDimensions.spacingXL),
            // Статус авторизации
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return Card(
                  color: state.maybeWhen(
                    authenticated: (_) => ThemeColors.successContainer,
                    orElse: () => ThemeColors.getSurfaceColorByBrightness(context),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(ThemeDimensions.cardPadding),
                    child: Column(
                      children: [
                        Text(
                          LocaleKeys.home_auth_status.tr(),
                          style: ThemeTextStyles.titleLarge(context),
                        ),
                        SizedBox(height: ThemeDimensions.spacingS),
                        state.maybeWhen(
                          authenticated: (user) => Column(
                            children: [
                              Text(
                                LocaleKeys.home_logged_in.tr(),
                                style: const TextStyle(
                                  color: ThemeColors.successDark,
                                ),
                              ),
                              SizedBox(height: ThemeDimensions.spacingXS),
                              Text(
                                user.name,
                                style: ThemeTextStyles.bodyMedium(context),
                              ),
                            ],
                          ),
                          orElse: () => Text(
                            LocaleKeys.home_not_authorized.tr(),
                            style: TextStyle(
                              color: ThemeColors.getSecondaryTextColorByBrightness(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: ThemeBorderStyles.cardBorderRadius(context),
        child: Container(
          padding: EdgeInsets.all(ThemeDimensions.cardPadding),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(ThemeDimensions.paddingM * 0.75),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ThemeDimensions.radiusS),
                ),
                child: Icon(icon, color: color, size: ThemeDimensions.iconL),
              ),
              SizedBox(width: ThemeDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ThemeTextStyles.cardTitle(context),
                    ),
                    SizedBox(height: ThemeDimensions.spacingXS),
                    Text(
                      description,
                      style: ThemeTextStyles.cardSubtitle(context),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: ThemeDimensions.iconXS, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
