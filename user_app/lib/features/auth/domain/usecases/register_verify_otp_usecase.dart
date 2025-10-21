import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterVerifyOtpUseCase {
  final AuthRepository repository;

  RegisterVerifyOtpUseCase(this.repository);

  Future<Either<Failure, AuthResponseEntity>> call({
    required String email,
    required String otp,
  }) async {
    return await repository.registerVerifyOtp(
      email: email,
      otp: otp,
    );
  }
}
