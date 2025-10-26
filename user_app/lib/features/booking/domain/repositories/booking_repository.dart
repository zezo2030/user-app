// Booking Repository Interface - Domain Layer
import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<BookingEntity> createBooking({
    required String branchId,
    required String hallId,
    required DateTime startTime,
    required int durationHours,
    required int persons,
  });
}
