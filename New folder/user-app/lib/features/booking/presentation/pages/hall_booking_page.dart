// Hall Booking Page - Presentation Layer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
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
import '../widgets/slot_selector.dart';
import '../../domain/entities/addon_entity.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/entities/time_slot_entity.dart';
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
  int? maxDurationForSlot;
  bool isClosedAtSelectedTime = false;
  String? availabilityMessage;
  bool isLoadingSlots = false;
  String? slotsError;
  int slotMinutes = 60;
  List<TimeSlotEntity> availableSlots = [];
  TimeSlotEntity? selectedSlot;

  // Mock add-ons data - in real app, this would come from API
  final List<AddOnEntity> availableAddOns = [
    const AddOnEntity(
      id: '11111111-1111-1111-1111-111111111111',
      name: 'Decoration Package',
      price: 150.0,
      quantity: 1,
    ),
    const AddOnEntity(
      id: '22222222-2222-2222-2222-222222222222',
      name: 'Sound System',
      price: 100.0,
      quantity: 1,
    ),
    const AddOnEntity(
      id: '33333333-3333-3333-3333-333333333333',
      name: 'Lighting Package',
      price: 80.0,
      quantity: 1,
    ),
    const AddOnEntity(
      id: '44444444-4444-4444-4444-444444444444',
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
      _loadAddOns();
      _requestQuote();
    });
  }

  Future<void> _loadAddOns() async {
    try {
      final response = await DioClient.instance.get(
        '${ApiConstants.baseUrl}/content/halls/${widget.hallId}/addons',
      );
      final data = response.data;
      if (data is List) {
        setState(() {
          availableAddOns
            ..clear()
            ..addAll(
              data.map(
                (e) => AddOnEntity(
                  id: e['id'] as String,
                  name: (e['name'] ?? '') as String,
                  price: (e['price'] as num?)?.toDouble() ?? 0.0,
                  quantity: (e['defaultQuantity'] as int?) ?? 1,
                ),
              ),
            );
        });
      }
    } catch (_) {
      // keep mock add-ons as fallback silently
    }
  }

  void _fetchSlotsForDate() {
    final date = selectedDate;
    if (date == null) {
      setState(() {
        availableSlots = [];
        slotsError = null;
        maxDurationForSlot = null;
        isClosedAtSelectedTime = false;
        availabilityMessage = null;
      });
      return;
    }

    final normalizedDate = DateTime(date.year, date.month, date.day);
    context.read<BookingCubit>().fetchHallSlots(
          hallId: widget.hallId,
          date: normalizedDate,
          durationHours: durationHours,
          persons: personsCount,
        );
  }

  void _computeMaxDurationFromSlots() {
    final date = selectedDate;
    final time = selectedTime;

    if (date == null || time == null) {
      setState(() {
        selectedSlot = null;
        maxDurationForSlot = null;
        isClosedAtSelectedTime = false;
        availabilityMessage = null;
      });
      return;
    }

    final targetStart = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    TimeSlotEntity? matchingSlot;
    for (final slot in availableSlots) {
      if (slot.start.isAtSameMomentAs(targetStart)) {
        matchingSlot = slot;
        break;
      }
    }

    if (matchingSlot == null) {
      setState(() {
        selectedSlot = null;
        maxDurationForSlot = 0;
        isClosedAtSelectedTime = true;
        availabilityMessage = 'hall_not_available'.tr();
      });
      return;
    }

    var maxHours = (matchingSlot.consecutiveSlots * slotMinutes) ~/ 60;
    if (maxHours == 0 && matchingSlot.consecutiveSlots > 0) {
      maxHours = 1;
    }

    final TimeSlotEntity resolvedSlot = matchingSlot;

    setState(() {
      selectedSlot = resolvedSlot;
      maxDurationForSlot = maxHours > 0 ? maxHours : 0;
      isClosedAtSelectedTime = maxDurationForSlot == 0;
      availabilityMessage =
          resolvedSlot.available ? null : 'hall_not_available'.tr();
    });

    if (maxDurationForSlot != null &&
        maxDurationForSlot! > 0 &&
        durationHours > maxDurationForSlot!) {
      setState(() {
        durationHours = maxDurationForSlot!;
      });
    }
  }

  void _onSlotSelected(TimeSlotEntity slot) {
    setState(() {
      selectedSlot = slot;
      selectedDate = DateTime(slot.start.year, slot.start.month, slot.start.day);
      selectedTime = TimeOfDay(hour: slot.start.hour, minute: slot.start.minute);
    });
    _computeMaxDurationFromSlots();
    _onBookingDetailsChanged();
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
          } else if (state is SlotsLoading) {
            setState(() {
              isLoadingSlots = true;
              slotsError = null;
            });
          } else if (state is SlotsLoaded) {
            setState(() {
              isLoadingSlots = false;
              slotsError = null;
              slotMinutes = state.hallSlots.slotMinutes;
              availableSlots = state.hallSlots.slots;
            });
            TimeSlotEntity? slotToSelect;
            if (selectedSlot != null) {
              for (final slot in state.hallSlots.slots) {
                if (slot.start.isAtSameMomentAs(selectedSlot!.start) &&
                    slot.available) {
                  slotToSelect = slot;
                  break;
                }
              }
            }
            if (slotToSelect == null) {
              for (final slot in state.hallSlots.slots) {
                if (slot.available) {
                  slotToSelect = slot;
                  break;
                }
              }
            }
            if (slotToSelect != null) {
              _onSlotSelected(slotToSelect);
            } else {
              setState(() {
                selectedSlot = null;
                selectedTime = null;
                maxDurationForSlot = null;
                isClosedAtSelectedTime = true;
                availabilityMessage = 'hall_not_available'.tr();
              });
            }
          } else if (state is SlotsError) {
            setState(() {
              isLoadingSlots = false;
              slotsError = state.message;
              availableSlots = [];
              maxDurationForSlot = null;
            });
          }
        },
        builder: (context, state) {
          final theme = Theme.of(context);
          final bool isLoading = state is BookingLoading;
          final bool isBookingEnabled =
              _canBook() &&
                  state is! BookingLoading &&
                  isAvailable &&
                  (maxDurationForSlot == null
                      ? true
                      : (maxDurationForSlot ?? 0) > 0) &&
                  !isClosedAtSelectedTime;
          final bool showGradient = isBookingEnabled || isLoading;
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
                    setState(() {
                      selectedDate = date;
                      selectedTime = null;
                      selectedSlot = null;
                      maxDurationForSlot = null;
                      isClosedAtSelectedTime = false;
                      availabilityMessage = null;
                    });
                    _fetchSlotsForDate();
                  },
                  onTimeChanged: null,
                  showTimeSelector: false,
                ),
                const SizedBox(height: 16),
                SlotSelector(
                  slots: availableSlots,
                  selectedSlot: selectedSlot,
                  slotMinutes: slotMinutes,
                  selectedDurationHours: durationHours,
                  isLoading: isLoadingSlots,
                  errorMessage: slotsError,
                  onSlotSelected: _onSlotSelected,
                ),
                const SizedBox(height: 16),

                // Duration Selector
                DurationSelector(
                  selectedDuration: durationHours,
                  maxDuration: maxDurationForSlot,
                  onDurationChanged: (duration) {
                    setState(() => durationHours = duration);
                    _onBookingDetailsChanged();
                    _fetchSlotsForDate();
                    _computeMaxDurationFromSlots();
                  },
                ),

                // Closed message if outside working hours
                if (isClosedAtSelectedTime ||
                    (maxDurationForSlot != null && maxDurationForSlot == 0))
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
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
                            availabilityMessage ?? 'الصالة مغلقة في هذا الوقت',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
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
                          .map((addOn) => {'id': addOn.id, 'quantity': 1})
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
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: showGradient
                          ? const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFFF5CAB),
                                Color(0xFFFF6A00),
                              ],
                            )
                          : null,
                      color: showGradient
                          ? null
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      onPressed:
                          isBookingEnabled ? () => _bookHall(context) : null,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Iconsax.calendar_1),
                      label: Text(
                        isLoading ? 'booking'.tr() : 'confirm_booking'.tr(),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            theme.colorScheme.onSurfaceVariant,
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
    return selectedSlot != null;
  }

  void _onBookingDetailsChanged() {
    if (_canBook()) {
      _checkAvailability();
      _requestQuote();
    }
  }

  void _checkAvailability() {
    if (!_canBook()) return;

    // منع التحقق إذا كان الوقت المحدد في الماضي
    final now = DateTime.now();
    final start = selectedSlot!.start;
    if (!start.isAfter(now)) {
      setState(() {
        isLoadingAvailability = false;
        isAvailable = false;
        availabilityMessage = 'لا يمكن الحجز في وقتٍ ماضٍ';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يمكن الحجز في وقتٍ ماضٍ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoadingAvailability = true;
    });

    context.read<BookingCubit>().checkAvailability(
      hallId: widget.hallId,
      startTime: start,
      durationHours: durationHours,
    );
  }

  void _requestQuote() {
    if (!_canBook()) return;

    // تحقق من عدم كون الوقت في الماضي قبل طلب التسعير
    final now = DateTime.now();
    final start = selectedSlot!.start;
    if (!start.isAfter(now)) {
      setState(() {
        isLoadingQuote = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يمكن الحجز في وقتٍ ماضٍ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoadingQuote = true;
    });

    context.read<BookingCubit>().getQuote(
      branchId: widget.branchId,
      hallId: widget.hallId,
      startTime: start,
      durationHours: durationHours,
      persons: personsCount,
      addOns: selectedAddOns,
      couponCode: couponCode,
    );
  }

  void _bookHall(BuildContext context) {
    if (!_canBook() || !isAvailable) return;

    // تحقق نهائي قبل الإرسال
    final now = DateTime.now();
    final start = selectedSlot!.start;
    if (!start.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يمكن الحجز في وقتٍ ماضٍ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<BookingCubit>().createBooking(
      branchId: widget.branchId,
      hallId: widget.hallId,
      startTime: start,
      durationHours: durationHours,
      persons: personsCount,
      couponCode: couponCode,
      addOns: selectedAddOns,
      specialRequests: specialRequests,
      contactPhone: contactPhone,
    );
  }
}
