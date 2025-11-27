// Get Hall Slots Use Case - Domain Layer
import '../entities/hall_slots_entity.dart';
import '../repositories/booking_repository.dart';

class GetHallSlotsUseCase {
  final BookingRepository repository;

  GetHallSlotsUseCase({required this.repository});

  Future<HallSlotsEntity> call({
    required String hallId,
    required DateTime date,
    int durationHours = 1,
    int? slotMinutes,
    int? persons,
  }) {
    return repository.getHallSlots(
      hallId: hallId,
      date: date,
      durationHours: durationHours,
      slotMinutes: slotMinutes,
      persons: persons,
    );
  }
}

