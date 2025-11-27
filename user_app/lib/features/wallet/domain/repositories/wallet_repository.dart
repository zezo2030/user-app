import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/wallet_entity.dart';
import '../entities/wallet_transaction_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletEntity>> getWalletBalance();
  
  Future<Either<Failure, List<WalletTransactionEntity>>> getTransactions({
    WalletTransactionType? type,
    WalletTransactionStatus? status,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, RechargeWalletResult>> rechargeWallet({
    required double amount,
    required String method,
  });
}

class RechargeWalletResult {
  final bool success;
  final String transactionId;
  final double amount;
  final double newBalance;
  final String? failureReason;

  RechargeWalletResult({
    required this.success,
    required this.transactionId,
    required this.amount,
    required this.newBalance,
    this.failureReason,
  });
}
