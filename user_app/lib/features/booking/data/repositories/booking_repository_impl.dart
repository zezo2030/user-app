// Booking Repository Implementation - Data Layer
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/booking_request_model.dart';
import '../models/quote_request_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
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
  }) async {
    try {
      final request = BookingRequestModel(
        branchId: branchId,
        hallId: hallId,
        startTime: startTime.toIso8601String(),
        durationHours: durationHours,
        persons: persons,
        couponCode: couponCode,
        addOns: addOns,
        specialRequests: specialRequests,
        contactPhone: contactPhone,
      );

      final bookingModel = await remoteDataSource.createBooking(request);
      return bookingModel;
    } catch (e) {
      print('❌ BookingRepository: Error creating booking: $e');
      rethrow;
    }
  }

  @override
  Future<QuoteEntity> getQuote({
    required String branchId,
    String? hallId, // جعل hallId اختياري
    required DateTime startTime,
    required int durationHours,
    required int persons,
    List<Map<String, dynamic>>? addOns,
    String? couponCode,
  }) async {
    try {
      final request = QuoteRequestModel(
        branchId: branchId,
        hallId: hallId, // hallId اختياري الآن
        startTime: startTime.toIso8601String(),
        durationHours: durationHours,
        persons: persons,
        addOns: addOns,
        couponCode: couponCode,
      );

      final quoteModel = await remoteDataSource.getQuote(request);
      return quoteModel;
    } catch (e) {
      print('❌ BookingRepository: Error getting quote: $e');
      rethrow;
    }
  }

  @override
  Future<bool> checkAvailability({
    required String hallId,
    required DateTime startTime,
    required int durationHours,
  }) async {
    try {
      return await remoteDataSource.checkAvailability(
        hallId,
        startTime.toIso8601String(),
        durationHours,
      );
    } catch (e) {
      print('❌ BookingRepository: Error checking availability: $e');
      rethrow;
    }
  }

  @override
  Future<bool> checkServerHealth() async {
    try {
      return await remoteDataSource.checkServerHealth();
    } catch (e) {
      print('❌ BookingRepository: Error checking server health: $e');
      return false;
    }
  }
}
