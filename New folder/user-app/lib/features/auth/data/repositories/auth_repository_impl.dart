import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/auth_response_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/update_profile_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuthResponseEntity>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        phone: phone,
        password: password,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String language = 'ar',
  }) async {
    try {
      print('🔄 Repository: Calling register for email: $email, name: $name');
      final result = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        language: language,
      );
      print('✅ Repository: Register result: ${result.toEntity()}');
      return Right(result.toEntity());
    } on DioException catch (e) {
      print('❌ Repository: Register DioException: ${e.toString()}');
      return Left(e.toFailure());
    } catch (e) {
      print('❌ Repository: Register Exception: ${e.toString()}');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendOtp({
    required String phone,
    String language = 'ar',
  }) async {
    try {
      print('🔄 Repository: Calling sendOtp for phone: $phone');
      final result = await remoteDataSource.sendOtp(
        phone: phone,
        language: language,
      );
      print('✅ Repository: SendOtp result: $result');
      return Right(result);
    } on DioException catch (e) {
      print('❌ Repository: SendOtp DioException: ${e.toString()}');
      return Left(e.toFailure());
    } catch (e) {
      print('❌ Repository: SendOtp Exception: ${e.toString()}');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      print('🔄 Repository: Calling verifyOtp for phone: $phone, otp: $otp');
      final result = await remoteDataSource.verifyOtp(
        phone: phone,
        otp: otp,
      );
      print('✅ Repository: VerifyOtp result: ${result.toEntity()}');
      return Right(result.toEntity());
    } on DioException catch (e) {
      print('❌ Repository: VerifyOtp DioException: ${e.toString()}');
      return Left(e.toFailure());
    } catch (e) {
      print('❌ Repository: VerifyOtp Exception: ${e.toString()}');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> registerSendOtp({
    required String phone,
    String language = 'ar',
  }) async {
    try {
      final result = await remoteDataSource.registerSendOtp(
        phone: phone,
        language: language,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> registerVerifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final result = await remoteDataSource.registerVerifyOtp(
        phone: phone,
        otp: otp,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> completeRegistration({
    required String phone,
    required String name,
    required String password,
    String language = 'ar',
  }) async {
    try {
      final result = await remoteDataSource.completeRegistration(
        phone: phone,
        name: name,
        password: password,
        language: language,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final result = await remoteDataSource.getProfile();
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final result = await remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
    UpdateProfileDto updateProfileDto,
  ) async {
    try {
      final result = await remoteDataSource.updateProfile(updateProfileDto);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> refreshProfile() async {
    try {
      final result = await remoteDataSource.refreshProfile();
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateLanguage(String language) async {
    try {
      final result = await remoteDataSource.updateLanguage(language);
      return Right(result);
    } on DioException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
