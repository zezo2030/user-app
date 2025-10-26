// Hall Booking Page - Presentation Layer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../widgets/date_time_selector.dart';
import '../widgets/duration_selector.dart';
import '../widgets/persons_input.dart';
import '../widgets/booking_summary_card.dart';

class HallBookingPage extends StatefulWidget {
  final String hallId;
  final String branchId;
  final String hallName;

  const HallBookingPage({
    Key? key,
    required this.hallId,
    required this.branchId,
    required this.hallName,
  }) : super(key: key);

  @override
  State<HallBookingPage> createState() => _HallBookingPageState();
}

class _HallBookingPageState extends State<HallBookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int durationHours = 2;
  int personsCount = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('book_hall'.tr()),
        centerTitle: true,
      ),
      body: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('booking_success'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hall Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Iconsax.home_2, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.hallName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'booking_hall_subtitle'.tr(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Time Selector
                DateTimeSelector(
                  selectedDate: selectedDate,
                  selectedTime: selectedTime,
                  onDateChanged: (date) => setState(() => selectedDate = date),
                  onTimeChanged: (time) => setState(() => selectedTime = time),
                ),

                // Duration Selector
                DurationSelector(
                  selectedDuration: durationHours,
                  onDurationChanged: (duration) => setState(() => durationHours = duration),
                ),

                // Persons Input
                PersonsInput(
                  personsCount: personsCount,
                  onPersonsChanged: (persons) => setState(() => personsCount = persons),
                ),

                // Booking Summary
                BookingSummaryCard(
                  hallName: widget.hallName,
                  selectedDate: selectedDate,
                  selectedTime: selectedTime,
                  durationHours: durationHours,
                  personsCount: personsCount,
                ),

                const SizedBox(height: 24),

                // Book Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _canBook() && state is! BookingLoading
                        ? () => _bookHall(context)
                        : null,
                    icon: state is BookingLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Iconsax.calendar_1),
                    label: Text(
                      state is BookingLoading ? 'booking'.tr() : 'confirm_booking'.tr(),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Validation Message
                if (!_canBook())
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.info_circle, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'complete_booking_details'.tr(),
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _canBook() {
    return selectedDate != null && selectedTime != null;
  }

  void _bookHall(BuildContext context) {
    if (!_canBook()) return;

    final DateTime startTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    context.read<BookingCubit>().createBooking(
      branchId: widget.branchId,
      hallId: widget.hallId,
      startTime: startTime,
      durationHours: durationHours,
      persons: personsCount,
    );
  }
}
