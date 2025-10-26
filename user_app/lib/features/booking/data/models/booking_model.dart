// Booking Model - Data Layer
import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.branchId,
    required super.hallId,
    required super.startTime,
    required super.durationHours,
    required super.persons,
    required super.totalPrice,
    required super.status,
    super.couponCode,
    super.discountAmount,
    super.specialRequests,
    super.contactPhone,
    super.cancelledAt,
    super.cancellationReason,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      branchId: json['branchId'] as String,
      hallId: json['hallId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      durationHours: json['durationHours'] as int,
      persons: json['persons'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      couponCode: json['couponCode'] as String?,
      discountAmount: json['discountAmount'] != null 
          ? (json['discountAmount'] as num).toDouble() 
          : null,
      specialRequests: json['specialRequests'] as String?,
      contactPhone: json['contactPhone'] as String?,
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt'] as String) 
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'branchId': branchId,
      'hallId': hallId,
      'startTime': startTime.toIso8601String(),
      'durationHours': durationHours,
      'persons': persons,
      'totalPrice': totalPrice,
      'status': status,
      'couponCode': couponCode,
      'discountAmount': discountAmount,
      'specialRequests': specialRequests,
      'contactPhone': contactPhone,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
