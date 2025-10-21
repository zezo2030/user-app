import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String email,
    String language = 'ar',
  }) async {
    return await repository.sendOtp(
      email: email,
      language: language,
    );
  }
}
