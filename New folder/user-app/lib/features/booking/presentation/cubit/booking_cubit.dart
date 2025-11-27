// Booking Cubit - Presentation Layer
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../../domain/usecases/get_quote_usecase.dart';
import '../../domain/usecases/check_availability_usecase.dart';
import '../../domain/usecases/check_server_health_usecase.dart';
import '../../domain/usecases/get_hall_slots_usecase.dart';
import '../../domain/entities/quote_entity.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final CreateBookingUseCase createBookingUseCase;
  final GetQuoteUseCase getQuoteUseCase;
  final CheckAvailabilityUseCase checkAvailabilityUseCase;
  final CheckServerHealthUseCase checkServerHealthUseCase;
  final GetHallSlotsUseCase getHallSlotsUseCase;

  BookingCubit({
    required this.createBookingUseCase,
    required this.getQuoteUseCase,
    required this.checkAvailabilityUseCase,
    required this.checkServerHealthUseCase,
    required this.getHallSlotsUseCase,
  }) : super(BookingInitial());

  Future<void> createBooking({
    required String branchId,
    required String hallId,
    required DateTime startTime,
    required int durationHours,
    required int persons,
    String? couponCode,
    List<Map<String, dynamic>>? addOns,
    String? specialRequests,
    String? contactPhone,
  }) async {
    emit(BookingLoading());

    try {
      // إنشاء الحجز والحصول على بياناته
      final booking = await createBookingUseCase.call(
        branchId: branchId,
        hallId: hallId,
        startTime: startTime,
        durationHours: durationHours,
        persons: persons,
        couponCode: couponCode,
        addOns: addOns,
        specialRequests: specialRequests,
        contactPhone: contactPhone,
      );

      // الحصول على عرض السعر للعرض التفصيلي
      QuoteEntity? quote;
      try {
        quote = await getQuoteUseCase.call(
          branchId: branchId,
          hallId: hallId,
          startTime: startTime,
          durationHours: durationHours,
          persons: persons,
          addOns: addOns,
          couponCode: couponCode,
        );
      } catch (e) {
        // إذا فشل الحصول على الـ quote، نستمر بدونها
        print('⚠️ BookingCubit: Failed to get quote for booking details: $e');
      }

      emit(BookingSuccessWithData(booking: booking, quote: quote));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  Future<void> getQuote({
    required String branchId,
    String? hallId, // جعل hallId اختياري
    required DateTime startTime,
    required int durationHours,
    required int persons,
    List<Map<String, dynamic>>? addOns,
    String? couponCode,
  }) async {
    emit(QuoteLoading());

    try {
      final quote = await getQuoteUseCase.call(
        branchId: branchId,
        hallId: hallId, // hallId اختياري الآن
        startTime: startTime,
        durationHours: durationHours,
        persons: persons,
        addOns: addOns,
        couponCode: couponCode,
      );

      emit(QuoteLoaded(quote: quote));
    } catch (e) {
      emit(QuoteError(message: e.toString()));
    }
  }

  Future<void> checkAvailability({
    required String hallId,
    required DateTime startTime,
    required int durationHours,
  }) async {
    emit(AvailabilityChecking());

    try {
      final isAvailable = await checkAvailabilityUseCase.call(
        hallId: hallId,
        startTime: startTime,
        durationHours: durationHours,
      );

      emit(AvailabilityChecked(isAvailable: isAvailable));
    } catch (e) {
      emit(AvailabilityError(message: e.toString()));
    }
  }

  Future<void> checkServerHealth() async {
    emit(ServerHealthChecking());

    try {
      final isHealthy = await checkServerHealthUseCase.call();
      emit(ServerHealthChecked(isHealthy: isHealthy));
    } catch (e) {
      emit(ServerHealthError(message: e.toString()));
    }
  }

  Future<void> fetchHallSlots({
    required String hallId,
    required DateTime date,
    int durationHours = 1,
    int? slotMinutes,
    int? persons,
  }) async {
    emit(SlotsLoading());

    try {
      final result = await getHallSlotsUseCase.call(
        hallId: hallId,
        date: date,
        durationHours: durationHours,
        slotMinutes: slotMinutes,
        persons: persons,
      );
      emit(SlotsLoaded(hallSlots: result));
    } catch (e) {
      emit(SlotsError(message: e.toString()));
    }
  }
}
