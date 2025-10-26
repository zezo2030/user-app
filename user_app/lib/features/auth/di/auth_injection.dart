import 'package:get_it/get_it.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/network/dio_client.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/send_otp_usecase.dart';
import '../domain/usecases/verify_otp_usecase.dart';
import '../domain/usecases/register_send_otp_usecase.dart';
import '../domain/usecases/register_verify_otp_usecase.dart';
import '../domain/usecases/get_profile_usecase.dart';
import '../domain/usecases/refresh_token_usecase.dart';
import '../presentation/cubit/auth_cubit.dart';
import '../../home/di/home_injection.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  
  // Network
  sl.registerLazySingleton(() => DioClient.instance);
  
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => RegisterSendOtpUseCase(sl()));
  sl.registerLazySingleton(() => RegisterVerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
  
  // Cubit
  sl.registerFactory(() => AuthCubit(
    loginUseCase: sl(),
    sendOtpUseCase: sl(),
    verifyOtpUseCase: sl(),
    registerSendOtpUseCase: sl(),
    registerVerifyOtpUseCase: sl(),
    getProfileUseCase: sl(),
    refreshTokenUseCase: sl(),
  ));

  // Initialize Home feature
  await initHome();
}

