import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/wallet_repository.dart';

class RechargeWalletUseCase {
  final WalletRepository repository;

  RechargeWalletUseCase(this.repository);

  Future<Either<Failure, RechargeWalletResult>> call({
    required double amount,
    required String method,
  }) {
    return repository.rechargeWallet(
      amount: amount,
      method: method,
    );
  }
}
