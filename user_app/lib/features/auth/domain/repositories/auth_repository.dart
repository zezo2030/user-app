import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_response_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Login with email/phone and password
  Future<Either<Failure, AuthResponseEntity>> login({
    required String identifier,
    required String password,
  });

  // Send OTP for login
  Future<Either<Failure, bool>> sendOtp({
    required String email,
    String language = 'ar',
  });

  // Verify OTP for login
  Future<Either<Failure, AuthResponseEntity>> verifyOtp({
    required String email,
    required String otp,
    String? name,
  });

  // Send OTP for registration
  Future<Either<Failure, bool>> registerSendOtp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String language = 'ar',
  });

  // Verify OTP for registration
  Future<Either<Failure, AuthResponseEntity>> registerVerifyOtp({
    required String email,
    required String otp,
  });

  // Get user profile
  Future<Either<Failure, UserEntity>> getProfile();

  // Refresh access token
  Future<Either<Failure, AuthResponseEntity>> refreshToken({
    required String refreshToken,
  });
}
