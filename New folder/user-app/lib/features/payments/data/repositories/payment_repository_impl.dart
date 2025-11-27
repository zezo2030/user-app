import '../../domain/entities/payment_entities.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';
import '../models/payment_models.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remote;

  PaymentRepositoryImpl({required this.remote});

  @override
  Future<PaymentIntentEntity> createIntent({
    required String bookingId,
    required String method,
  }) async {
    final req = CreatePaymentIntentRequestModel(
      bookingId: bookingId,
      method: method,
    );
    final res = await remote.createPaymentIntent(req);
    return PaymentIntentEntity(
      paymentId: res.paymentId,
      chargeId: res.chargeId,
      method: method,
    );
  }

  @override
  Future<ConfirmPaymentResultEntity> confirm({
    required String bookingId,
    required String paymentId,
    String? chargeId,
  }) async {
    final req = ConfirmPaymentRequestModel(
      bookingId: bookingId,
      paymentId: paymentId,
      chargeId: chargeId,
    );
    final res = await remote.confirmPayment(req);
    return ConfirmPaymentResultEntity(
      success: res.success,
      transactionId: res.transactionId,
      paidAt: res.paidAt,
    );
  }
}
