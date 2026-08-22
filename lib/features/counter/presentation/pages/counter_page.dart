import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:qde_eco_bahor/core/di/injection_container.dart';
import 'package:qde_eco_bahor/core/theme/theme_dimensions.dart';
import 'package:qde_eco_bahor/core/widgets/language_toggle.dart';
import 'package:qde_eco_bahor/core/widgets/theme_toggle.dart';
import 'package:qde_eco_bahor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_eco_bahor/features/counter/presentation/bloc/counter_bloc.dart';
import 'package:qde_eco_bahor/generated/locale_keys.g.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final GlobalKey<_CounterContentState> _counterContentKey = GlobalKey();

  void _startShowcase() {
    _counterContentKey.currentState?.startShowcase();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<AuthBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<CounterBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: Text(LocaleKeys.counter_title.tr()),
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                return authState.maybeWhen(
                  authenticated: (_) => IconButton(
                    icon: const Icon(Icons.help_outline),
                    tooltip: 'Показать подсказки',
                    onPressed: _startShowcase,
                  ),
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
            const LanguageToggle(),
            const ThemeToggle(),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return authState.maybeWhen(
              authenticated: (user) => _CounterContent(
                key: _counterContentKey,
                user: user,
              ),
              orElse: () => Center(
                child: Text(LocaleKeys.counter_login_required.tr()),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CounterContent extends StatefulWidget {
  final dynamic user;

  const _CounterContent({super.key, required this.user});

  @override
  State<_CounterContent> createState() => _CounterContentState();
}

class _CounterContentState extends State<_CounterContent> {
  final GlobalKey _mainShowcaseKey = GlobalKey();
  final GlobalKey _incrementKey = GlobalKey();
  final GlobalKey _decrementKey = GlobalKey();
  final GlobalKey _resetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startShowcase();
    });
  }

  void startShowcase() {
    final showcaseKeys = [
      _mainShowcaseKey,
      _decrementKey,
      _resetKey,
      _incrementKey,
    ];
    ShowCaseWidget.of(context).startShowCase(showcaseKeys);
  }

  void _startShowcase() {
    startShowcase();
  }

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: _mainShowcaseKey,
      title: LocaleKeys.counter_title.tr(),
      description: LocaleKeys.counter_description.tr(),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(ThemeDimensions.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Информация о пользователе из модуля auth
              Card(
                child: Container(
                  padding: EdgeInsets.all(ThemeDimensions.cardPadding),
                  child: Column(
                    children: [
                      Text(
                        LocaleKeys.counter_user.tr(),
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.user.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 18.sp,
                            ),
                      ),
                      Text(
                        widget.user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 14.sp,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 48.h),
              // Значение счетчика
              BlocBuilder<CounterBloc, CounterState>(
                builder: (context, state) {
                  return Text(
                    '${state.value}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 72.sp,
                        ),
                  );
                },
              ),
              SizedBox(height: 48.h),
              // Кнопки управления
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Showcase(
                    key: _decrementKey,
                    title: LocaleKeys.counter_decrement.tr(),
                    description: LocaleKeys.counter_decrement_tooltip.tr(),
                    child: FloatingActionButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(const CounterEvent.decrement());
                      },
                      heroTag: 'decrement',
                      child: Icon(Icons.remove, size: 24.sp),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Showcase(
                    key: _resetKey,
                    title: LocaleKeys.counter_reset.tr(),
                    description: LocaleKeys.counter_reset_tooltip.tr(),
                    child: FloatingActionButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(const CounterEvent.reset());
                      },
                      heroTag: 'reset',
                      child: Icon(Icons.refresh, size: 24.sp),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Showcase(
                    key: _incrementKey,
                    title: LocaleKeys.counter_increment.tr(),
                    description: LocaleKeys.counter_increment_tooltip.tr(),
                    child: FloatingActionButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(const CounterEvent.increment());
                      },
                      heroTag: 'increment',
                      child: Icon(Icons.add, size: 24.sp),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
