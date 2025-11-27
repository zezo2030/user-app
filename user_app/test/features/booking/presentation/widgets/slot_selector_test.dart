import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/booking/data/models/time_slot_model.dart';
import 'package:user_app/features/booking/domain/entities/time_slot_entity.dart';
import 'package:user_app/features/booking/presentation/widgets/slot_selector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await EasyLocalization.ensureInitialized();
  });

  TimeSlotEntity buildSlot(
    DateTime start, {
    bool available = true,
    int consecutiveSlots = 1,
  }) {
    return TimeSlotModel(
      start: start,
      end: start.add(const Duration(hours: 1)),
      available: available,
      consecutiveSlots: consecutiveSlots,
    );
  }

  testWidgets('SlotSelector renders slots and handles selection', (
    tester,
  ) async {
    final slots = [
      buildSlot(
        DateTime(2025, 11, 7, 17, 0),
        available: true,
        consecutiveSlots: 2,
      ),
      buildSlot(
        DateTime(2025, 11, 7, 18, 0),
        available: false,
        consecutiveSlots: 1,
      ),
    ];

    TimeSlotEntity? tappedSlot;

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: MaterialApp(
          home: Scaffold(
            body: SlotSelector(
              slots: slots,
              selectedSlot: null,
              slotMinutes: 60,
              isLoading: false,
              errorMessage: null,
              onSlotSelected: (slot) => tappedSlot = slot,
              selectedDurationHours: null,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('17:00 - 18:00'), findsOneWidget);
    expect(find.text('18:00 - 19:00'), findsOneWidget);

    await tester.tap(find.text('17:00 - 18:00'));
    await tester.pump();
    expect(tappedSlot, isNotNull);
    expect(tappedSlot!.start.hour, 17);

    tappedSlot = null;
    await tester.tap(find.text('18:00 - 19:00'));
    await tester.pump();
    expect(tappedSlot, isNull);
  });
}
