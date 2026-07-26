import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../bloc/app_settings_bloc.dart';
import '../../features/auth/data/api/auth_api.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Сеть
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Глобальный Блок Настроек (Тема и Язык)
  sl.registerLazySingleton<AppSettingsBloc>(() => AppSettingsBloc());

  // Фича Auth
  sl.registerLazySingleton<AuthApi>(() => AuthApi(sl<DioClient>().dio));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl<AuthApi>()));
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));
}
