// Booking Repository Implementation - Data Layer
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/booking_request_model.dart';

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
  }) async {
    try {
      final request = BookingRequestModel(
        branchId: branchId,
        hallId: hallId,
        startTime: startTime.toIso8601String(),
        durationHours: durationHours,
        persons: persons,
      );

      final bookingModel = await remoteDataSource.createBooking(request);
      return bookingModel;
    } catch (e) {
      print('❌ BookingRepository: Error creating booking: $e');
      rethrow;
    }
  }
}
