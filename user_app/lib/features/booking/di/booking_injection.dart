// Booking Dependency Injection
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../data/datasources/booking_remote_datasource.dart';
import '../data/repositories/booking_repository_impl.dart';
import '../domain/repositories/booking_repository.dart';
import '../domain/usecases/create_booking_usecase.dart';
import '../presentation/cubit/booking_cubit.dart';

final sl = GetIt.instance;

void initBookingInjection() {
  // Data Sources
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repositories
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: sl<BookingRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton<CreateBookingUseCase>(
    () => CreateBookingUseCase(repository: sl<BookingRepository>()),
  );

  // Cubits
  sl.registerFactory<BookingCubit>(
    () => BookingCubit(createBookingUseCase: sl<CreateBookingUseCase>()),
  );
}
