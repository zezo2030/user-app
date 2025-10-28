// Payment data models and requests
class CreatePaymentIntentRequestModel {
  final String bookingId;
  final String method; // CREDIT_CARD

  CreatePaymentIntentRequestModel({
    required this.bookingId,
    required this.method,
  });

  Map<String, dynamic> toJson() => {'bookingId': bookingId, 'method': method};
}

class PaymentIntentResponseModel {
  final String paymentId;
  final String clientSecret;

  PaymentIntentResponseModel({
    required this.paymentId,
    required this.clientSecret,
  });

  factory PaymentIntentResponseModel.fromJson(Map<String, dynamic> json) {
    // API may wrap data with { data: {...} }
    final Map<String, dynamic> data = json['data'] is Map<String, dynamic>
        ? json['data']
        : json;
    return PaymentIntentResponseModel(
      paymentId: data['paymentId']?.toString() ?? data['id']?.toString() ?? '',
      clientSecret: data['clientSecret']?.toString() ?? '',
    );
  }
}

class ConfirmPaymentRequestModel {
  final String bookingId;
  final String paymentId;
  final String clientSecret;

  ConfirmPaymentRequestModel({
    required this.bookingId,
    required this.paymentId,
    required this.clientSecret,
  });

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'paymentId': paymentId,
    'gatewayPayload': {'clientSecret': clientSecret},
  };
}

class ConfirmPaymentResponseModel {
  final bool success;
  final String? transactionId;
  final DateTime? paidAt;

  ConfirmPaymentResponseModel({
    required this.success,
    this.transactionId,
    this.paidAt,
  });

  factory ConfirmPaymentResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] is Map<String, dynamic>
        ? json['data']
        : json;
    return ConfirmPaymentResponseModel(
      success: data['success'] == true,
      transactionId: data['transactionId']?.toString(),
      paidAt: data['paidAt'] != null
          ? DateTime.tryParse(data['paidAt'].toString())
          : null,
    );
  }
}
