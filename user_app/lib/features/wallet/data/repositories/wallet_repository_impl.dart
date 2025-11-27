import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/wallet_transaction_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';
import '../models/recharge_request_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remote;

  WalletRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, WalletEntity>> getWalletBalance() async {
    try {
      final wallet = await remote.getWalletBalance();
      return Right(wallet.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WalletTransactionEntity>>> getTransactions({
    WalletTransactionType? type,
    WalletTransactionStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final transactions = await remote.getTransactions(
        type: type,
        status: status,
        page: page,
        pageSize: pageSize,
      );
      return Right(transactions.map((t) => t.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RechargeWalletResult>> rechargeWallet({
    required double amount,
    required String method,
  }) async {
    try {
      final request = RechargeRequestModel(amount: amount, method: method);
      final response = await remote.rechargeWallet(request);

      double toDouble(dynamic value, [double defaultValue = 0.0]) {
        if (value == null) return defaultValue;
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? defaultValue;
        return defaultValue;
      }

      final result = RechargeWalletResult(
        success: response['success'] as bool? ?? false,
        transactionId: response['transactionId'] as String? ?? '',
        amount: toDouble(response['amount'], amount),
        newBalance: toDouble(response['newBalance']),
        failureReason: response['failureReason'] as String?,
      );

      if (result.success) {
        return Right(result);
      } else {
        return Left(
          ServerFailure(message: result.failureReason ?? 'فشل شحن المحفظة'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
