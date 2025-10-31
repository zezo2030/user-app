import '../entities/payment_entities.dart';
import '../repositories/payment_repository.dart';

class ConfirmPaymentUseCase {
  final PaymentRepository repository;

  ConfirmPaymentUseCase({required this.repository});

  Future<ConfirmPaymentResultEntity> call({
    required String bookingId,
    required String paymentId,
    String? chargeId,
  }) {
    return repository.confirm(
      bookingId: bookingId,
      paymentId: paymentId,
      chargeId: chargeId,
    );
  }
}
