// Payment domain entities
import 'package:equatable/equatable.dart';

class PaymentIntentEntity extends Equatable {
  final String paymentId;
  final String clientSecret;
  final String method; // e.g., CREDIT_CARD

  const PaymentIntentEntity({
    required this.paymentId,
    required this.clientSecret,
    required this.method,
  });

  @override
  List<Object?> get props => [paymentId, clientSecret, method];
}

class ConfirmPaymentResultEntity extends Equatable {
  final bool success;
  final String? transactionId;
  final DateTime? paidAt;

  const ConfirmPaymentResultEntity({
    required this.success,
    this.transactionId,
    this.paidAt,
  });

  @override
  List<Object?> get props => [success, transactionId, paidAt];
}
