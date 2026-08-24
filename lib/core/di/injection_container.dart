import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:qde_eco_bahor/core/network/api_client.dart';
import 'package:qde_eco_bahor/core/network/network_info.dart';
import 'package:qde_eco_bahor/core/services/analytics_service.dart';
import 'package:qde_eco_bahor/core/services/storage_service.dart';
import 'package:qde_eco_bahor/core/services/theme_service.dart';
import 'package:qde_eco_bahor/features/admin/add_product/add_product_bloc.dart';
import 'package:qde_eco_bahor/features/admin/add_product/add_product_remote_datasource.dart';
import 'package:qde_eco_bahor/features/admin/add_product/add_product_repository.dart';
import 'package:qde_eco_bahor/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:qde_eco_bahor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:qde_eco_bahor/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/admin/add_product/add_product_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../firebase_options.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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

  // Auth Feature
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<AddProductRemoteDataSource>(
    () => AddProductRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<AddProductRepository>(
    () => AddProductRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt(),
    ),
  );
  getIt.registerFactory<AddProductBloc>(
    () => AddProductBloc(
      repository: getIt(),
    ),
  );
}
