import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:qde_eco_bahor/core/di/injection_container.dart';
import 'package:qde_eco_bahor/core/notifications/notification_service.dart';
import 'package:qde_eco_bahor/core/router/app_router.dart';
import 'package:qde_eco_bahor/core/services/theme_service.dart';
import 'package:qde_eco_bahor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_eco_bahor/generated/locale_keys.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  await initDependencies();

  if (getIt.isRegistered<NotificationService>()) {
    try {
      final notificationService = getIt<NotificationService>();
      await notificationService.initialize();

      final token = await notificationService.getFCMToken();
      if (token != null) {
        print('FCM Token: $token');
        print('Используйте этот токен для отправки тестовых уведомлений из Firebase Console');
      }
    } catch (e) {
      print('Ошибка инициализации уведомлений: $e');
    }
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      startLocale: Locale('en'),
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: BlocProvider(
        create: (context) => getIt<AuthBloc>()..add(const AuthEvent.checkAuthStatus()),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = getIt<ThemeService>();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _themeService.themeModeStream.listen((mode) {
      if (mounted) {
        setState(() {
          _themeMode = mode;
        });
      }
    });
  }

  Future<void> _loadTheme() async {
    final mode = await _themeService.getThemeMode();
    if (mounted) {
      setState(() {
        _themeMode = mode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) {
        return ScreenUtilInit(
          designSize: const Size(375, 812), // iPhone X design size
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              title: LocaleKeys.app_name,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              themeMode: _themeMode,
              routerConfig: AppRouter.router,
            );
          },
        );
      },
    );
  }
}
