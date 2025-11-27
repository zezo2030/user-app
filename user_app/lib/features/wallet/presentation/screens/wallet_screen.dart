import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';
import '../../domain/entities/wallet_transaction_entity.dart';
import 'recharge_wallet_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_wallet'.tr()),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => GetIt.instance<WalletCubit>()..loadWallet(),
        child: BlocConsumer<WalletCubit, WalletState>(
          listener: (context, state) {
            if (state is WalletError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            } else if (state is WalletRechargeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('recharge_success'.tr()),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<WalletCubit>().loadWallet();
              context.read<WalletCubit>().loadTransactions();
            } else if (state is WalletRechargeFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is WalletLoading || state is WalletInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WalletError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<WalletCubit>().loadWallet();
                      },
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              );
            } else if (state is WalletLoaded ||
                state is WalletRechargeLoading ||
                state is WalletRechargeSuccess ||
                state is WalletRechargeFailed) {
              final wallet = state is WalletLoaded
                  ? state.wallet
                  : state is WalletRechargeLoading
                      ? state.wallet
                      : state is WalletRechargeSuccess
                          ? state.wallet
                          : state is WalletRechargeFailed
                              ? state.wallet
                              : null;
              final List<WalletTransactionEntity> transactions = state is WalletLoaded
                  ? state.transactions
                  : state is WalletRechargeLoading
                      ? state.transactions
                      : state is WalletRechargeSuccess
                          ? state.transactions
                          : state is WalletRechargeFailed
                              ? state.transactions
                              : <WalletTransactionEntity>[];

              if (wallet == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<WalletCubit>().loadWallet();
                  context.read<WalletCubit>().loadTransactions();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCard(context, wallet),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'transaction_history'.tr(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              final walletCubit = context.read<WalletCubit>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: walletCubit,
                                    child: const RechargeWalletScreen(),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Iconsax.add, size: 18),
                            label: Text('recharge_wallet'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (state is WalletLoaded && state.isLoadingTransactions)
                        const Center(child: CircularProgressIndicator())
                      else if (transactions.isEmpty)
                        _buildEmptyTransactions(context)
                      else
                        _buildTransactionsList(context, transactions),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, wallet) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryRed, Color(0xFFFF6A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'wallet_balance'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${wallet.balance.toStringAsFixed(2)} ${wallet.currency}',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceInfo(
                context,
                'total_earned_amount'.tr(),
                '${wallet.totalEarned.toStringAsFixed(2)} ${wallet.currency}',
              ),
              _buildBalanceInfo(
                context,
                'total_spent_amount'.tr(),
                '${wallet.totalSpent.toStringAsFixed(2)} ${wallet.currency}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyTransactions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Iconsax.receipt_2,
              size: 64,
              color: AppColors.luxuryTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'no_transactions'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.luxuryTextSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(
      BuildContext context, List<WalletTransactionEntity> transactions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(context, transaction);
      },
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, WalletTransactionEntity transaction) {
    final isDeposit = transaction.type == WalletTransactionType.deposit;
    final isSuccess = transaction.status == WalletTransactionStatus.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.luxuryBorderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDeposit
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDeposit ? Iconsax.arrow_down_2 : Iconsax.arrow_up_2,
              color: isDeposit ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDeposit ? 'deposit'.tr() : 'withdrawal'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(transaction.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.luxuryTextSecondary,
                      ),
                ),
                if (transaction.method != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.method!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.luxuryTextSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDeposit ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ${'currency'.tr()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDeposit ? Colors.green : Colors.red,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSuccess ? 'success'.tr() : 'failed'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSuccess ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
