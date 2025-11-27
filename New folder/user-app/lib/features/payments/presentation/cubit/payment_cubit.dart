import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../../domain/entities/payment_entities.dart';
import '../../domain/usecases/create_payment_intent_usecase.dart';
import '../../domain/usecases/confirm_payment_usecase.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentIntentCreated extends PaymentState {
  final PaymentIntentEntity intent;
  PaymentIntentCreated(this.intent);
}

class PaymentSuccess extends PaymentState {
  final ConfirmPaymentResultEntity result;
  PaymentSuccess(this.result);
}

class PaymentFailure extends PaymentState {
  final String message;
  PaymentFailure(this.message);
}

class PaymentCubit extends Cubit<PaymentState> {
  final CreatePaymentIntentUseCase createIntentUseCase;
  final ConfirmPaymentUseCase confirmPaymentUseCase;

  PaymentCubit({
    required this.createIntentUseCase,
    required this.confirmPaymentUseCase,
  }) : super(PaymentInitial());

  Future<void> payForBooking({
    required BookingEntity booking,
    String method = 'credit_card',
  }) async {
    emit(PaymentLoading());
    try {
      final intent = await createIntentUseCase(
        bookingId: booking.id,
        method: method,
      );
      emit(PaymentIntentCreated(intent));

      // If payment method is wallet, skip Tap SDK and confirm directly
      if (method == 'wallet') {
        final confirmResult = await confirmPaymentUseCase(
          bookingId: booking.id,
          paymentId: intent.paymentId,
          chargeId: intent.chargeId,
        );

        if (confirmResult.success) {
          emit(PaymentSuccess(confirmResult));
        } else {
          emit(PaymentFailure('فشل تأكيد الدفع من المحفظة'));
        }
        return;
      }

      // For other payment methods, use Tap SDK
      final bool sdkSuccess = await _openTapCheckout(
        amount: booking.totalPrice,
        currency: 'SAR',
        chargeId: intent.chargeId,
      );

      if (!sdkSuccess) {
        emit(PaymentFailure('تم إلغاء الدفع'));
        return;
      }

      final confirmResult = await confirmPaymentUseCase(
        bookingId: booking.id,
        paymentId: intent.paymentId,
        chargeId: intent.chargeId,
      );

      if (confirmResult.success) {
        emit(PaymentSuccess(confirmResult));
      } else {
        emit(PaymentFailure('فشل تأكيد الدفع'));
      }
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }

  // Placeholder: استبدلها باستدعاء Tap SDK الفعلي
  Future<bool> _openTapCheckout({
    required double amount,
    required String currency,
    required String chargeId,
  }) async {
    // TODO: دمج Tap Flutter SDK وارجاع true عند نجاح الدفع
    return true;
  }
}
