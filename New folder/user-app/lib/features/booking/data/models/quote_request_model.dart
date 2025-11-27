// Quote Request Model - Data Layer
class QuoteRequestModel {
  final String branchId;
  final String? hallId; // جعل hallId اختياري
  final String startTime;
  final int durationHours;
  final int persons;
  final List<Map<String, dynamic>>? addOns;
  final String? couponCode;

  QuoteRequestModel({
    required this.branchId,
    this.hallId, // جعل hallId اختياري
    required this.startTime,
    required this.durationHours,
    required this.persons,
    this.addOns,
    this.couponCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'branchId': branchId,
      'startTime': startTime,
      'durationHours': durationHours,
      'persons': persons,
      'addOns': addOns,
      'couponCode': couponCode,
    };

    // إضافة hallId فقط إذا كان موجوداً
    if (hallId != null) {
      json['hallId'] = hallId;
    }

    return json;
  }
}
