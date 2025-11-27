import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';

class RechargeWalletScreen extends StatefulWidget {
  const RechargeWalletScreen({super.key});

  @override
  State<RechargeWalletScreen> createState() => _RechargeWalletScreenState();
}

class _RechargeWalletScreenState extends State<RechargeWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedMethod = 'credit_card';

  final List<Map<String, String>> _paymentMethods = [
    {
      'value': 'credit_card',
      'label_ar': 'بطاقة ائتمانية',
      'label_en': 'Credit Card',
    },
    {
      'value': 'debit_card',
      'label_ar': 'بطاقة مدفوعة مسبقاً',
      'label_en': 'Debit Card',
    },
    {
      'value': 'bank_transfer',
      'label_ar': 'تحويل بنكي',
      'label_en': 'Bank Transfer',
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _getMethodLabel(String method) {
    final methodData = _paymentMethods.firstWhere(
      (m) => m['value'] == method,
      orElse: () => {'label_ar': method, 'label_en': method},
    );
    return context.locale.languageCode == 'ar'
        ? methodData['label_ar']!
        : methodData['label_en']!;
  }

  void _submitRecharge() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'recharge_amount'.tr()} ${'must_be_greater_than_zero'.tr()}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      context.read<WalletCubit>().rechargeWallet(
        amount: amount,
        method: _selectedMethod,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('recharge_wallet'.tr()), centerTitle: true),
      body: BlocListener<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state is WalletRechargeSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('recharge_success'.tr()),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is WalletRechargeFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'recharge_amount'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: 'SAR ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Iconsax.money_recive),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '${'recharge_amount'.tr()} ${'is_required'.tr()}';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return '${'recharge_amount'.tr()} ${'must_be_greater_than_zero'.tr()}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'select_payment_method'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ..._paymentMethods.map((method) {
                  final value = method['value']!;
                  return RadioListTile<String>(
                    title: Text(_getMethodLabel(value)),
                    value: value,
                    groupValue: _selectedMethod,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedMethod = newValue!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  );
                }),
                const SizedBox(height: 32),
                BlocBuilder<WalletCubit, WalletState>(
                  builder: (context, state) {
                    final isLoading = state is WalletRechargeLoading;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _submitRecharge,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Iconsax.wallet_3, size: 20),
                        label: Text(
                          isLoading
                              ? 'processing'.tr()
                              : 'recharge_wallet'.tr(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
