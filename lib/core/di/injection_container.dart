import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qde_eco_bahor/core/network/api_client.dart';
import 'package:qde_eco_bahor/core/network/network_info.dart';
import 'package:qde_eco_bahor/core/notifications/notification_handler.dart';
import 'package:qde_eco_bahor/core/notifications/notification_service.dart';
import 'package:qde_eco_bahor/core/services/analytics_service.dart';
import 'package:qde_eco_bahor/core/services/storage_service.dart';
import 'package:qde_eco_bahor/core/services/theme_service.dart';
import 'package:qde_eco_bahor/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:qde_eco_bahor/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:qde_eco_bahor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:qde_eco_bahor/features/auth/domain/repositories/auth_repository.dart';
import 'package:qde_eco_bahor/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:qde_eco_bahor/features/auth/domain/usecases/login_usecase.dart';
import 'package:qde_eco_bahor/features/auth/domain/usecases/logout_usecase.dart';
import 'package:qde_eco_bahor/features/auth/domain/usecases/register_usecase.dart';
import 'package:qde_eco_bahor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_eco_bahor/features/counter/presentation/bloc/counter_bloc.dart';
import 'package:qde_eco_bahor/features/example_feature/data/datasources/example_remote_datasource.dart';
import 'package:qde_eco_bahor/features/example_feature/data/repositories/example_repository_impl.dart';
import 'package:qde_eco_bahor/features/example_feature/domain/repositories/example_repository.dart';
import 'package:qde_eco_bahor/features/example_feature/domain/usecases/get_example_data.dart';
import 'package:qde_eco_bahor/features/example_feature/presentation/bloc/example_bloc.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    getIt.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
    firebaseInitialized = true;
  } catch (e) {}
  getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );

  // Network
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt()));
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt()),
  );

  // Storage
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Services
  getIt.registerLazySingleton<StorageService>(
    () => StorageServiceImpl(getIt()),
  );
  getIt.registerLazySingleton<AnalyticsService>(
    () => AnalyticsServiceImpl(),
  );
  getIt.registerLazySingleton<ThemeService>(
    () => ThemeServiceImpl(getIt()),
  );

  if (firebaseInitialized) {
    getIt.registerLazySingleton<NotificationHandler>(
      () => NotificationHandler(getIt()),
    );
    getIt.registerLazySingleton<NotificationService>(
      () => NotificationService(
        localNotifications: getIt(),
        firebaseMessaging: getIt<FirebaseMessaging>(),
        handler: getIt(),
      ),
    );
  }

  getIt.registerLazySingleton<ExampleRemoteDataSource>(
    () => ExampleRemoteDataSourceImpl(client: getIt<ApiClient>().dio),
  );

  getIt.registerLazySingleton<ExampleRepository>(
    () => ExampleRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton(() => GetExampleData(getIt()));

  getIt.registerFactory(
    () => ExampleBloc(getExampleData: getIt()),
  );

  // Auth Feature
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt()));
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      logoutUseCase: getIt(),
      getCurrentUserUseCase: getIt(),
    ),
  );

  // Counter Feature
  getIt.registerFactory(() => CounterBloc());
}
