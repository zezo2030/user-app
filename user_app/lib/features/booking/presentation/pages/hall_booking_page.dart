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
import '../widgets/coupon_input.dart';
import '../widgets/addons_selector.dart';
import '../widgets/special_requests_input.dart';
import '../widgets/contact_phone_input.dart';
import '../widgets/price_breakdown_card.dart';
import '../../domain/entities/addon_entity.dart';
import '../../domain/entities/quote_entity.dart';
import 'booking_details_page.dart';

class HallBookingPage extends StatefulWidget {
  final String hallId;
  final String branchId;
  final String hallName;

  const HallBookingPage({
    super.key,
    required this.hallId,
    required this.branchId,
    required this.hallName,
  });

  @override
  State<HallBookingPage> createState() => _HallBookingPageState();
}

class _HallBookingPageState extends State<HallBookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int durationHours = 2;
  int personsCount = 10;

  // New fields
  String? couponCode;
  List<String> selectedAddOnIds = [];
  List<Map<String, dynamic>> selectedAddOns = [];
  String? specialRequests;
  String? contactPhone;

  // State management
  QuoteEntity? currentQuote;
  bool isAvailable = true;
  bool isLoadingQuote = false;
  bool isLoadingAvailability = false;

  // Mock add-ons data - in real app, this would come from API
  final List<AddOnEntity> availableAddOns = [
    const AddOnEntity(
      id: '1',
      name: 'Decoration Package',
      price: 150.0,
      quantity: 1,
    ),
    const AddOnEntity(id: '2', name: 'Sound System', price: 100.0, quantity: 1),
    const AddOnEntity(
      id: '3',
      name: 'Lighting Package',
      price: 80.0,
      quantity: 1,
    ),
    const AddOnEntity(
      id: '4',
      name: 'Catering Service',
      price: 200.0,
      quantity: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initial quote request
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('book_hall'.tr()), centerTitle: true),
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
          } else if (state is BookingSuccessWithData) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('booking_success'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            // الانتقال إلى صفحة تفاصيل الحجز
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailsPage(
                  booking: state.booking,
                  quote: state.quote,
                ),
              ),
            );
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is QuoteLoaded) {
            setState(() {
              currentQuote = state.quote;
              isLoadingQuote = false;
            });
          } else if (state is QuoteError) {
            setState(() {
              isLoadingQuote = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AvailabilityChecked) {
            setState(() {
              isAvailable = state.isAvailable;
              isLoadingAvailability = false;
            });
            if (!state.isAvailable) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('hall_not_available'.tr()),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } else if (state is AvailabilityError) {
            setState(() {
              isLoadingAvailability = false;
            });
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
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'booking_hall_subtitle'.tr(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade600),
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
                  onDateChanged: (date) {
                    setState(() => selectedDate = date);
                    _onBookingDetailsChanged();
                  },
                  onTimeChanged: (time) {
                    setState(() => selectedTime = time);
                    _onBookingDetailsChanged();
                  },
                ),

                // Duration Selector
                DurationSelector(
                  selectedDuration: durationHours,
                  onDurationChanged: (duration) {
                    setState(() => durationHours = duration);
                    _onBookingDetailsChanged();
                  },
                ),

                // Persons Input
                PersonsInput(
                  personsCount: personsCount,
                  onPersonsChanged: (persons) {
                    setState(() => personsCount = persons);
                    _onBookingDetailsChanged();
                  },
                ),

                // Add-ons Selector
                AddOnsSelector(
                  availableAddOns: availableAddOns,
                  selectedAddOnIds: selectedAddOnIds,
                  onAddOnsChanged: (addOnIds) {
                    setState(() {
                      selectedAddOnIds = addOnIds;
                      selectedAddOns = availableAddOns
                          .where((addOn) => addOnIds.contains(addOn.id))
                          .map(
                            (addOn) => {
                              'id': addOn.id,
                              'name': addOn.name,
                              'price': addOn.price,
                              'quantity': 1,
                            },
                          )
                          .toList();
                    });
                    _onBookingDetailsChanged();
                  },
                ),

                // Coupon Input
                CouponInputWidget(
                  onCouponChanged: (coupon) {
                    setState(() => couponCode = coupon);
                    _onBookingDetailsChanged();
                  },
                  isLoading: isLoadingQuote,
                ),

                // Special Requests Input
                SpecialRequestsInput(
                  onRequestsChanged: (requests) {
                    setState(() => specialRequests = requests);
                  },
                ),

                // Contact Phone Input
                ContactPhoneInput(
                  onPhoneChanged: (phone) {
                    setState(() => contactPhone = phone);
                  },
                ),

                // Price Breakdown Card
                PriceBreakdownCard(
                  quote: currentQuote,
                  isLoading: isLoadingQuote,
                  durationHours: durationHours,
                ),

                // Booking Summary
                BookingSummaryCard(
                  hallName: widget.hallName,
                  selectedDate: selectedDate,
                  selectedTime: selectedTime,
                  durationHours: durationHours,
                  personsCount: personsCount,
                  quote: currentQuote,
                  couponCode: couponCode,
                  selectedAddOns: selectedAddOns,
                  specialRequests: specialRequests,
                  contactPhone: contactPhone,
                ),

                const SizedBox(height: 24),

                // Availability Status
                if (isLoadingAvailability)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'checking_availability'.tr(),
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                  )
                else if (!isAvailable)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.close_circle, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'hall_not_available'.tr(),
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Book Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _canBook() && state is! BookingLoading && isAvailable
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
                      state is BookingLoading
                          ? 'booking'.tr()
                          : 'confirm_booking'.tr(),
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
                        Icon(
                          Iconsax.info_circle,
                          color: Colors.orange.shade700,
                        ),
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

  void _onBookingDetailsChanged() {
    if (_canBook()) {
      _checkAvailability();
      _requestQuote();
    }
  }

  void _checkAvailability() {
    if (!_canBook()) return;

    setState(() {
      isLoadingAvailability = true;
    });

    final DateTime startTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    context.read<BookingCubit>().checkAvailability(
      hallId: widget.hallId,
      startTime: startTime,
      durationHours: durationHours,
    );
  }

  void _requestQuote() {
    if (!_canBook()) return;

    setState(() {
      isLoadingQuote = true;
    });

    final DateTime startTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    context.read<BookingCubit>().getQuote(
      branchId: widget.branchId,
      hallId: widget.hallId,
      startTime: startTime,
      durationHours: durationHours,
      persons: personsCount,
      addOns: selectedAddOns,
      couponCode: couponCode,
    );
  }

  void _bookHall(BuildContext context) {
    if (!_canBook() || !isAvailable) return;

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
      couponCode: couponCode,
      addOns: selectedAddOns,
      specialRequests: specialRequests,
      contactPhone: contactPhone,
    );
  }
}
