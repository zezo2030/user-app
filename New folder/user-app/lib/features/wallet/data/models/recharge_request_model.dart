class RechargeRequestModel {
  final double amount;
  final String method;

  const RechargeRequestModel({
    required this.amount,
    required this.method,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'method': method,
    };
  }
}
