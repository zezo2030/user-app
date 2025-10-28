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

      // Here we would open a payment sheet; for now, directly confirm using clientSecret
      final confirmResult = await confirmPaymentUseCase(
        bookingId: booking.id,
        paymentId: intent.paymentId,
        clientSecret: intent.clientSecret,
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
}
