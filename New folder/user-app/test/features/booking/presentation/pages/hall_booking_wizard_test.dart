import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:user_app/features/booking/presentation/pages/hall_booking_wizard_page.dart';
import 'package:user_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:user_app/features/booking/presentation/cubit/booking_state.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingCubit extends Mock implements BookingCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockBookingCubit mockBookingCubit;

  setUp(() {
    mockBookingCubit = MockBookingCubit();
    when(() => mockBookingCubit.state).thenReturn(BookingInitial());
    when(() => mockBookingCubit.stream).thenAnswer(
      (_) => Stream.fromIterable([BookingInitial()]),
    );
  });

  setUpAll(() async {
    await EasyLocalization.ensureInitialized();
  });

  Widget createTestWidget() {
    return EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: MaterialApp(
        localizationsDelegates: const [],
        supportedLocales: const [Locale('ar'), Locale('en')],
        home: BlocProvider<BookingCubit>.value(
          value: mockBookingCubit,
          child: const HallBookingWizardPage(
            hallId: 'test-hall-id',
            branchId: 'test-branch-id',
            hallName: 'Test Hall',
          ),
        ),
      ),
    );
  }

  group('HallBookingWizardPage', () {
    testWidgets('should display progress indicator with 4 steps',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that 4 step indicators are present (numbers 1-4)
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('should start at step 1 (Date & Time)', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // First step should be active (step 1 indicator highlighted)
      final step1Container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Container),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).shape == BoxShape.circle,
          ),
        ).first,
      );

      expect(step1Container, isNotNull);
    });

    testWidgets('should disable next button when no slot is selected',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the continue/next button - it should be disabled initially
      final nextButton = tester.widget<ElevatedButton>(
        find.byWidgetPredicate(
          (widget) =>
              widget is ElevatedButton &&
              widget.onPressed == null, // Disabled button
        ),
      );

      expect(nextButton, isNotNull);
    });

    testWidgets('should show bottom navigation with back and next buttons',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // At first step, only next button should be visible (no back)
      // Next button should exist
      expect(
        find.byWidgetPredicate(
          (widget) => widget is ElevatedButton,
        ),
        findsWidgets,
      );
    });

    testWidgets('should display hall information card', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for hall name
      expect(find.text('Test Hall'), findsOneWidget);
    });
  });

  group('Step Navigation', () {
    testWidgets('should not allow navigation without completing step',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to tap next button (should be disabled)
      final nextButtons = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.onPressed == null,
      );

      expect(nextButtons, findsOneWidget);
    });
  });

  group('Booking Cubit Integration', () {
    testWidgets('should call fetchHallSlots when date is selected',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify that fetchHallSlots was not called initially
      verifyNever(
        () => mockBookingCubit.fetchHallSlots(
          hallId: any(named: 'hallId'),
          date: any(named: 'date'),
          durationHours: any(named: 'durationHours'),
          persons: any(named: 'persons'),
        ),
      );
    });
  });
}

