import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_wallet_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/recharge_wallet_usecase.dart';
import '../../domain/entities/wallet_transaction_entity.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final GetWalletUseCase getWalletUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final RechargeWalletUseCase rechargeWalletUseCase;

  WalletCubit({
    required this.getWalletUseCase,
    required this.getTransactionsUseCase,
    required this.rechargeWalletUseCase,
  }) : super(WalletInitial());

  Future<void> loadWallet() async {
    emit(WalletLoading());
    final result = await getWalletUseCase();
    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (wallet) => emit(WalletLoaded(wallet: wallet)),
    );
  }

  Future<void> loadTransactions({
    WalletTransactionType? type,
    WalletTransactionStatus? status,
    int page = 1,
  }) async {
    if (state is WalletLoaded) {
      final currentState = state as WalletLoaded;
      if (page == 1) {
        emit(WalletLoaded(
          wallet: currentState.wallet,
          transactions: [],
          isLoadingTransactions: true,
        ));
      }

      final result = await getTransactionsUseCase(
        type: type,
        status: status,
        page: page,
        pageSize: 20,
      );

      result.fold(
        (failure) => emit(WalletError(failure.message)),
        (transactions) {
          if (state is WalletLoaded) {
            final currentState = state as WalletLoaded;
            final allTransactions = page == 1
                ? transactions
                : [...currentState.transactions, ...transactions];
            emit(WalletLoaded(
              wallet: currentState.wallet,
              transactions: allTransactions,
              hasMoreTransactions: transactions.length == 20,
            ));
          }
        },
      );
    }
  }

  Future<void> rechargeWallet({
    required double amount,
    required String method,
  }) async {
    if (state is WalletLoaded) {
      final currentState = state as WalletLoaded;
      emit(WalletRechargeLoading(
        wallet: currentState.wallet,
        transactions: currentState.transactions,
      ));
    } else {
      emit(WalletRechargeLoading());
    }

    final result = await rechargeWalletUseCase(
      amount: amount,
      method: method,
    );

    result.fold(
      (failure) {
        if (state is WalletRechargeLoading) {
          final currentState = state as WalletRechargeLoading;
          emit(WalletRechargeFailed(
            wallet: currentState.wallet,
            transactions: currentState.transactions,
            error: failure.message,
          ));
        } else {
          emit(WalletError(failure.message));
        }
      },
      (rechargeResult) {
        if (state is WalletRechargeLoading) {
          final currentState = state as WalletRechargeLoading;
          // Reload wallet to get updated balance
          loadWallet();
          emit(WalletRechargeSuccess(
            wallet: currentState.wallet,
            transactions: currentState.transactions,
            newBalance: rechargeResult.newBalance,
          ));
        }
      },
    );
  }
}
