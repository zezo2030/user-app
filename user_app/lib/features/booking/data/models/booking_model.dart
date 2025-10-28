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
    int _asInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      final s = v?.toString();
      return int.tryParse(s ?? '') ?? 0;
    }

    double _asDouble(dynamic v) {
      if (v is double) return v;
      if (v is num) return v.toDouble();
      final s = v?.toString();
      return double.tryParse(s ?? '') ?? 0.0;
    }

    DateTime _asDate(dynamic v) {
      if (v is DateTime) return v;
      return DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();
    }

    DateTime? _asDateOrNull(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    return BookingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      branchId: json['branchId'] as String,
      hallId: json['hallId'] as String,
      startTime: _asDate(json['startTime']),
      durationHours: _asInt(json['durationHours']),
      persons: _asInt(json['persons']),
      totalPrice: _asDouble(json['totalPrice']),
      status: json['status'] as String,
      couponCode: json['couponCode'] as String?,
      discountAmount: json['discountAmount'] != null
          ? _asDouble(json['discountAmount'])
          : null,
      specialRequests: json['specialRequests'] as String?,
      contactPhone: json['contactPhone'] as String?,
      cancelledAt: _asDateOrNull(json['cancelledAt']),
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: _asDate(json['createdAt']),
      updatedAt: _asDate(json['updatedAt']),
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
