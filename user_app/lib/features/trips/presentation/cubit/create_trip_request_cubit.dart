import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/create_trip_request_input.dart';
import '../../domain/entities/trip_addon_entity.dart';
import '../../domain/usecases/create_trip_request_usecase.dart';
import 'create_trip_request_state.dart';

class CreateTripRequestCubit extends Cubit<CreateTripRequestState> {
  CreateTripRequestCubit({
    required this.createTripRequestUseCase,
  })  : _selectedDate = DateTime.now().add(const Duration(days: 1)),
        super(CreateTripRequestState.initial());

  final CreateTripRequestUseCase createTripRequestUseCase;

  String? selectedBranchId;
  String? selectedHallId;
  String schoolName = '';
  int studentsCount = 20;
  int? accompanyingAdults = 2;
  DateTime _selectedDate;
  String? preferredTime;
  int? durationHours = 2;
  String contactPersonName = '';
  String contactPhone = '';
  String? contactEmail;
  String? specialRequirements;
  String? paymentMethod;
  final List<TripAddOnEntity> _addOns = [];

  DateTime get preferredDate => _selectedDate;
  List<TripAddOnEntity> get addOns => List.unmodifiable(_addOns);

  bool get isValidBasicInfo =>
      selectedBranchId != null &&
      selectedBranchId!.isNotEmpty &&
      selectedHallId != null &&
      selectedHallId!.isNotEmpty &&
      schoolName.isNotEmpty &&
      contactPersonName.isNotEmpty &&
      contactPhone.length >= 8 &&
      studentsCount > 0;

  void updateSelectedBranchId(String? value) {
    selectedBranchId = value;
    // Reset hall selection when branch changes
    selectedHallId = null;
  }

  void updateSelectedHallId(String? value) {
    selectedHallId = value;
  }

  void updateSchoolName(String value) {
    schoolName = value;
  }

  void updateStudentsCount(int value) {
    studentsCount = value;
  }

  void updateAccompanyingAdults(int? value) {
    accompanyingAdults = value;
  }

  void updatePreferredDate(DateTime value) {
    _selectedDate = value;
  }

  void updatePreferredTime(String? value) {
    preferredTime = value;
  }

  void updateDurationHours(int? value) {
    durationHours = value;
  }

  void updateContactPersonName(String value) {
    contactPersonName = value;
  }

  void updateContactPhone(String value) {
    contactPhone = value;
  }

  void updateContactEmail(String? value) {
    contactEmail = value;
  }

  void updateSpecialRequirements(String? value) {
    specialRequirements = value;
  }

  void updatePaymentMethod(String? value) {
    paymentMethod = value;
  }

  void addAddon(TripAddOnEntity addon) {
    _addOns.removeWhere((a) => a.id == addon.id);
    _addOns.add(addon);
  }

  void removeAddon(String addonId) {
    _addOns.removeWhere((addon) => addon.id == addonId);
  }

  Future<void> submit() async {
    if (!isValidBasicInfo) {
      emit(
        state.copyWith(
          errorMessage: 'يرجى إكمال بيانات المدرسة ومعلومات التواصل واختيار الفرع والصالة.',
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final input = CreateTripRequestInput(
        branchId: selectedBranchId,
        hallId: selectedHallId,
        schoolName: schoolName,
        studentsCount: studentsCount,
        accompanyingAdults: accompanyingAdults,
        preferredDate: _selectedDate,
        preferredTime: preferredTime,
        durationHours: durationHours,
        contactPersonName: contactPersonName,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        specialRequirements: specialRequirements,
        addOns: _addOns,
        paymentMethod: paymentMethod,
      );

      final requestId = await createTripRequestUseCase(input);

      emit(
        state.copyWith(
          isSubmitting: false,
          requestId: requestId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

