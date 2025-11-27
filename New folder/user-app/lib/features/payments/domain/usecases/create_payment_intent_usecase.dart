import '../entities/payment_entities.dart';
import '../repositories/payment_repository.dart';

class CreatePaymentIntentUseCase {
  final PaymentRepository repository;

  CreatePaymentIntentUseCase({required this.repository});

  Future<PaymentIntentEntity> call({
    required String bookingId,
    required String method,
  }) {
    return repository.createIntent(bookingId: bookingId, method: method);
  }
}
