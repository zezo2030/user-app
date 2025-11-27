import 'package:equatable/equatable.dart';
import 'time_slot_entity.dart';

class HallSlotsEntity extends Equatable {
  final int slotMinutes;
  final List<TimeSlotEntity> slots;

  const HallSlotsEntity({
    required this.slotMinutes,
    required this.slots,
  });

  @override
  List<Object?> get props => [slotMinutes, slots];
}

