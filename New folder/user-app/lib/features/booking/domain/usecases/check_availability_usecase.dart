// Check Availability UseCase - Domain Layer
import '../repositories/booking_repository.dart';

class CheckAvailabilityUseCase {
  final BookingRepository repository;

  CheckAvailabilityUseCase({required this.repository});

  Future<bool> call({
    required String hallId,
    required DateTime startTime,
    required int durationHours,
  }) async {
    return await repository.checkAvailability(
      hallId: hallId,
      startTime: startTime,
      durationHours: durationHours,
    );
  }
}
