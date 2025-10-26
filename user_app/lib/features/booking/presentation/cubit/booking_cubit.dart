// Booking Cubit - Presentation Layer
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final CreateBookingUseCase createBookingUseCase;

  BookingCubit({required this.createBookingUseCase}) : super(BookingInitial());

  Future<void> createBooking({
    required String branchId,
    required String hallId,
    required DateTime startTime,
    required int durationHours,
    required int persons,
  }) async {
    emit(BookingLoading());
    
    try {
      await createBookingUseCase.call(
        branchId: branchId,
        hallId: hallId,
        startTime: startTime,
        durationHours: durationHours,
        persons: persons,
      );
      
      emit(BookingSuccess());
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }
}
