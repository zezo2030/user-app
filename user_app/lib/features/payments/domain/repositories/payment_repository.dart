import '../entities/payment_entities.dart';

abstract class PaymentRepository {
  Future<PaymentIntentEntity> createIntent({
    required String bookingId,
    required String method,
  });

  Future<ConfirmPaymentResultEntity> confirm({
    required String bookingId,
    required String paymentId,
    String? chargeId,
  });
}
