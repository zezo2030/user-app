// Booking Repository Interface - Domain Layer
import '../entities/booking_entity.dart';
import '../entities/quote_entity.dart';
import '../entities/hall_slots_entity.dart';

abstract class BookingRepository {
  Future<BookingEntity> createBooking({
    required String branchId,
    required String hallId,
    required DateTime startTime,
    required int durationHours,
    required int persons,
    String? couponCode,
    List<Map<String, dynamic>>? addOns,
    String? specialRequests,
    String? contactPhone,
  });

  Future<QuoteEntity> getQuote({
    required String branchId,
    String? hallId, // جعل hallId اختياري
    required DateTime startTime,
    required int durationHours,
    required int persons,
    List<Map<String, dynamic>>? addOns,
    String? couponCode,
  });

  Future<bool> checkAvailability({
    required String hallId,
    required DateTime startTime,
    required int durationHours,
  });

  Future<bool> checkServerHealth();

  Future<HallSlotsEntity> getHallSlots({
    required String hallId,
    required DateTime date,
    int durationHours = 1,
    int? slotMinutes,
    int? persons,
  });
}
