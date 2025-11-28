// Create Event Request Page - Presentation Layer
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../cubit/event_request_cubit.dart';
import '../cubit/event_request_state.dart';
import '../../../branches/data/branches_api.dart';
import '../../../branches/data/branches_repository.dart';
import '../../../home/data/datasources/home_remote_datasource.dart';
import '../../../home/data/models/branch_model.dart';
import '../../../home/data/models/hall_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/di/auth_injection.dart';
import '../../../booking/presentation/cubit/booking_cubit.dart';
import '../../../booking/presentation/cubit/booking_state.dart';
import '../../../booking/presentation/widgets/slot_selector.dart';
import '../../../booking/presentation/widgets/date_time_selector.dart';
import '../../../booking/domain/entities/time_slot_entity.dart';

class CreateEventRequestPage extends StatefulWidget {
  final String? branchId;

  const CreateEventRequestPage({super.key, this.branchId});

  @override
  State<CreateEventRequestPage> createState() => _CreateEventRequestPageState();
}

class _CreateEventRequestPageState extends State<CreateEventRequestPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  String? _selectedBranchId;
  String? _selectedHallId;
  DateTime? _selectedDate;
  TimeSlotEntity? _selectedSlot;
  int _durationHours = 2;

  // Slots state
  bool _isLoadingSlots = false;
  String? _slotsError;
  int _slotMinutes = 60;
  List<TimeSlotEntity> _availableSlots = [];
  int? _maxDurationForSlot;
  int _persons = 10;
  bool _decorated = false;
  String? _notes;
  List<BranchModel> _branches = [];
  List<HallModel> _halls = [];
  bool _loadingBranches = true;

  final List<String> _eventTypes = [
    'birthday',
    'graduation',
    'family',
    'corporate',
    'wedding',
    'other',
  ];

  String _getEventTypeTranslation(String type) {
    switch (type) {
      case 'birthday':
        return 'event_type_birthday'.tr();
      case 'graduation':
        return 'event_type_graduation'.tr();
      case 'family':
        return 'event_type_family'.tr();
      case 'corporate':
        return 'event_type_corporate'.tr();
      case 'wedding':
        return 'event_type_wedding'.tr();
      case 'other':
        return 'event_type_other'.tr();
      default:
        return type;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBranches();
    // If branchId is provided, set it and load halls
    if (widget.branchId != null) {
      _selectedBranchId = widget.branchId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadHalls(widget.branchId!);
      });
    }
  }

  Future<void> _loadBranches() async {
    setState(() => _loadingBranches = true);
    try {
      final repo = BranchesRepositoryImpl(api: BranchesApi());
      final branchEntities = await repo.getAllBranches(includeInactive: false);
      setState(() {
        _branches = branchEntities
            .map((e) => BranchModel.fromEntity(e))
            .toList();
        _loadingBranches = false;
      });
    } catch (e) {
      setState(() => _loadingBranches = false);
    }
  }

  Future<void> _loadHalls(String branchId) async {
    try {
      final ds = HomeRemoteDataSourceImpl(dio: DioClient.instance);
      final halls = await ds.getHallsByBranch(branchId);
      setState(() {
        _halls = halls;
        if (_selectedHallId != null &&
            !_halls.any((h) => h.id == _selectedHallId)) {
          _selectedHallId = null;
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  void _selectDate(DateTime date, BuildContext? cubitContext) {
    setState(() {
      _selectedDate = date;
      _selectedSlot = null;
    });
    if (_selectedHallId != null && cubitContext != null) {
      _fetchSlotsForDate(cubitContext);
    }
  }

  void _fetchSlotsForDate([BuildContext? cubitContext]) {
    final date = _selectedDate;
    final hallId = _selectedHallId;

    if (date == null || hallId == null) {
      setState(() {
        _availableSlots = [];
        _slotsError = null;
        _maxDurationForSlot = null;
        _selectedSlot = null;
      });
      return;
    }

    final ctx = cubitContext ?? context;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    ctx.read<BookingCubit>().fetchHallSlots(
      hallId: hallId,
      date: normalizedDate,
      durationHours: _durationHours,
      persons: _persons,
    );
  }

  void _onSlotSelected(TimeSlotEntity slot) {
    setState(() {
      _selectedSlot = slot;
      _selectedDate = DateTime(
        slot.start.year,
        slot.start.month,
        slot.start.day,
      );
    });
    _computeMaxDurationFromSlots();
  }

  void _computeMaxDurationFromSlots() {
    final slot = _selectedSlot;
    if (slot == null) {
      setState(() {
        _maxDurationForSlot = null;
      });
      return;
    }

    var maxHours = (slot.consecutiveSlots * _slotMinutes) ~/ 60;
    if (maxHours == 0 && slot.consecutiveSlots > 0) {
      maxHours = 1;
    }

    setState(() {
      _maxDurationForSlot = maxHours > 0 ? maxHours : 0;
    });

    if (_maxDurationForSlot != null &&
        _maxDurationForSlot! > 0 &&
        _durationHours > _maxDurationForSlot!) {
      setState(() {
        _durationHours = _maxDurationForSlot!;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التاريخ والوقت')),
      );
      return;
    }
    if (_selectedBranchId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار الفرع')));
      return;
    }

    final startTime = _selectedSlot!.start;

    context.read<EventRequestCubit>().createRequest(
      type: _selectedType!,
      branchId: _selectedBranchId!,
      hallId: _selectedHallId,
      startTime: startTime,
      durationHours: _durationHours,
      persons: _persons,
      decorated: _decorated,
      notes: _notes?.isEmpty == true ? null : _notes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<BookingCubit>(),
        ),
        BlocProvider(
          create: (_) => sl<EventRequestCubit>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('إنشاء طلب حجز خاص')),
        body: BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is SlotsLoading) {
              setState(() {
                _isLoadingSlots = true;
                _slotsError = null;
              });
            } else if (state is SlotsLoaded) {
              // Only process slots if hall is still selected
              if (_selectedHallId == null) {
                setState(() {
                  _isLoadingSlots = false;
                  _slotsError = null;
                  _availableSlots = [];
                  _maxDurationForSlot = null;
                });
                return;
              }

              setState(() {
                _isLoadingSlots = false;
                _slotsError = null;
                _slotMinutes = state.hallSlots.slotMinutes;
                _availableSlots = state.hallSlots.slots;
              });

              // Auto-select first available slot if none selected
              if (_selectedSlot == null && _availableSlots.isNotEmpty) {
                final availableSlots = _availableSlots
                    .where((slot) => slot.available)
                    .toList();
                if (availableSlots.isNotEmpty) {
                  _onSlotSelected(availableSlots.first);
                }
              } else if (_selectedSlot != null) {
                // Re-select slot if still available
                final matchingSlot = _availableSlots
                    .where(
                      (slot) =>
                          slot.start.isAtSameMomentAs(_selectedSlot!.start) &&
                          slot.available,
                    )
                    .firstOrNull;
                if (matchingSlot != null) {
                  _onSlotSelected(matchingSlot);
                } else {
                  setState(() {
                    _selectedSlot = null;
                  });
                }
              }
            } else if (state is SlotsError) {
              // Only show error if hall is selected
              if (_selectedHallId != null) {
                setState(() {
                  _isLoadingSlots = false;
                  _slotsError = state.message;
                  _availableSlots = [];
                  _maxDurationForSlot = null;
                });
              } else {
                setState(() {
                  _isLoadingSlots = false;
                  _slotsError = null;
                  _availableSlots = [];
                  _maxDurationForSlot = null;
                });
              }
            }
          },
          child: BlocListener<EventRequestCubit, EventRequestState>(
            listener: (context, state) {
              if (state is EventRequestCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إنشاء الطلب بنجاح')),
                );
                Navigator.pop(context);
              } else if (state is EventRequestCreateError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'event_type'.tr()),
                      initialValue: _selectedType,
                      items: _eventTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getEventTypeTranslation(type)),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedType = value),
                      validator: (value) =>
                          value == null ? 'يرجى اختيار نوع المناسبة' : null,
                    ),
                    const SizedBox(height: 16),

                    // Branch
                    _loadingBranches
                        ? const CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'الفرع',
                            ),
                            initialValue: _selectedBranchId,
                            items: _branches.map((branch) {
                              return DropdownMenuItem(
                                value: branch.id,
                                child: Text(branch.nameAr),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBranchId = value;
                                _selectedHallId = null;
                                _selectedSlot = null;
                                _selectedDate = null;
                                _availableSlots = [];
                              });
                              if (value != null) _loadHalls(value);
                            },
                            validator: (value) =>
                                value == null ? 'يرجى اختيار الفرع' : null,
                          ),
                    const SizedBox(height: 16),

                    // Hall (optional)
                    if (_selectedBranchId != null && _halls.isNotEmpty)
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'الصالة (اختياري)',
                        ),
                        initialValue: _selectedHallId,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('لا يوجد'),
                          ),
                          ..._halls.map((hall) {
                            return DropdownMenuItem(
                              value: hall.id,
                              child: Text(hall.nameAr),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedHallId = value;
                            _selectedSlot = null;
                            _availableSlots = [];
                            _slotsError = null;
                            _maxDurationForSlot = null;
                          });
                          // Only fetch slots if both hall and date are selected
                          if (value != null && _selectedDate != null) {
                            // Fetch slots for the selected hall and date
                            // Use WidgetsBinding to ensure context is available
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _fetchSlotsForDate();
                            });
                          } else if (value == null) {
                            // Clear slots if hall is deselected
                            setState(() {
                              _selectedSlot = null;
                              _availableSlots = [];
                              _slotsError = null;
                              _maxDurationForSlot = null;
                            });
                          }
                        },
                      ),
                    if (_selectedBranchId != null && _halls.isNotEmpty)
                      const SizedBox(height: 16),

                    // Date Selector
                    Builder(
                      builder: (builderContext) => DateTimeSelector(
                        selectedDate: _selectedDate,
                        selectedTime: null,
                        onDateChanged: (date) =>
                            _selectDate(date, builderContext),
                        onTimeChanged: null,
                        showTimeSelector: false,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Slot Selector (only if hall and date are selected, and either loading, has slots, or has error)
                    if (_selectedHallId != null &&
                        _selectedDate != null &&
                        (_isLoadingSlots ||
                            _availableSlots.isNotEmpty ||
                            _slotsError != null))
                      SlotSelector(
                        slots: _availableSlots,
                        selectedSlot: _selectedSlot,
                        slotMinutes: _slotMinutes,
                        selectedDurationHours: _durationHours,
                        isLoading: _isLoadingSlots,
                        errorMessage: _slotsError,
                        onSlotSelected: _onSlotSelected,
                      ),
                    // Message if date is selected but no hall
                    if (_selectedHallId == null && _selectedDate != null)
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.info_circle,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'يرجى اختيار الصالة لعرض الأوقات المتاحة',
                                  style: TextStyle(color: Colors.blue.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Message if slots are empty but hall and date are selected (and not loading, no error)
                    if (_selectedHallId != null &&
                        _selectedDate != null &&
                        !_isLoadingSlots &&
                        _slotsError == null &&
                        _availableSlots.isEmpty)
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.info_circle,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'لا توجد أوقات متاحة في هذا التاريخ',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Duration
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'المدة (ساعة)',
                        helperText:
                            _maxDurationForSlot != null &&
                                _maxDurationForSlot! > 0
                            ? 'الحد الأقصى: $_maxDurationForSlot ساعة'
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _durationHours.toString(),
                      onChanged: (value) {
                        final hours = int.tryParse(value) ?? 2;
                        setState(() {
                          _durationHours = hours;
                        });
                        if (_selectedHallId != null && _selectedDate != null) {
                          // Use WidgetsBinding to ensure context is available
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _fetchSlotsForDate();
                            _computeMaxDurationFromSlots();
                          });
                        }
                      },
                      validator: (value) {
                        final hours = int.tryParse(value ?? '');
                        if (hours == null || hours < 1) {
                          return 'يرجى إدخال مدة صحيحة';
                        }
                        if (_maxDurationForSlot != null &&
                            _maxDurationForSlot! > 0 &&
                            hours > _maxDurationForSlot!) {
                          return 'المدة لا يمكن أن تتجاوز $_maxDurationForSlot ساعة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Persons
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'عدد الأشخاص',
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _persons.toString(),
                      onChanged: (value) {
                        _persons = int.tryParse(value) ?? 10;
                      },
                      validator: (value) {
                        final persons = int.tryParse(value ?? '');
                        if (persons == null || persons < 1) {
                          return 'يرجى إدخال عدد صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Decorated
                    CheckboxListTile(
                      title: const Text('ديكور'),
                      value: _decorated,
                      onChanged: (value) =>
                          setState(() => _decorated = value ?? false),
                    ),

                    // Notes
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                      ),
                      maxLines: 3,
                      onChanged: (value) => _notes = value,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    BlocBuilder<EventRequestCubit, EventRequestState>(
                      builder: (context, state) {
                        final isLoading = state is EventRequestCreating;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : const Text('إرسال الطلب'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
