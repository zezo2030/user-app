import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/booking/data/models/time_slot_model.dart';

void main() {
  test('TimeSlotModel parses JSON correctly', () {
    final json = {
      'start': '2025-11-07T17:00:00.000Z',
      'end': '2025-11-07T18:00:00.000Z',
      'available': true,
      'consecutiveSlots': 3,
    };

    final model = TimeSlotModel.fromJson(json);

    expect(model.available, isTrue);
    expect(model.consecutiveSlots, 3);
    final startIso = json['start']! as String;
    final endIso = json['end']! as String;

    expect(model.start, DateTime.parse(startIso).toLocal());
    expect(model.end, DateTime.parse(endIso).toLocal());
  });
}

