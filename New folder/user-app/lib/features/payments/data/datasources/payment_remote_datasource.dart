import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/payment_models.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentIntentResponseModel> createPaymentIntent(
    CreatePaymentIntentRequestModel request,
  );

  Future<ConfirmPaymentResponseModel> confirmPayment(
    ConfirmPaymentRequestModel request,
  );
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaymentIntentResponseModel> createPaymentIntent(
    CreatePaymentIntentRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}/payments/intent',
        data: request.toJson(),
      );
      if (response.data == null) {
        throw Exception('Payment intent response is null');
      }
      return PaymentIntentResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Create intent failed: ${e.message}');
    }
  }

  @override
  Future<ConfirmPaymentResponseModel> confirmPayment(
    ConfirmPaymentRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}/payments/confirm',
        data: request.toJson(),
      );
      if (response.data == null) {
        throw Exception('Confirm payment response is null');
      }
      return ConfirmPaymentResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Confirm payment failed: ${e.message}');
    }
  }
}
