// Booking Request Model - Data Layer
class BookingRequestModel {
  final String branchId;
  final String hallId;
  final String startTime;
  final int durationHours;
  final int persons;

  BookingRequestModel({
    required this.branchId,
    required this.hallId,
    required this.startTime,
    required this.durationHours,
    required this.persons,
  });

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'hallId': hallId,
      'startTime': startTime,
      'durationHours': durationHours,
      'persons': persons,
    };
  }
}
