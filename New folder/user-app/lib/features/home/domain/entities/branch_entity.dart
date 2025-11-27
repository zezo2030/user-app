import 'package:equatable/equatable.dart';

class BranchEntity extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final String location;
  final int capacity;
  final String status; // 'active', 'inactive', 'maintenance'
  final String? descriptionAr;
  final String? descriptionEn;
  final String? contactPhone;
  final Map<String, dynamic>? workingHours;
  final List<String>? amenities;
  final String? videoUrl;
  final String? coverImage;
  final List<String>? images;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final int? reviewsCount;
  final List<dynamic>? offers;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BranchEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.location,
    required this.capacity,
    required this.status,
    this.descriptionAr,
    this.descriptionEn,
    this.contactPhone,
    this.workingHours,
    this.amenities,
    this.videoUrl,
    this.coverImage,
    this.images,
    this.latitude,
    this.longitude,
    this.rating,
    this.reviewsCount,
    this.offers,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    location,
    capacity,
    status,
    descriptionAr,
    descriptionEn,
    contactPhone,
    workingHours,
    amenities,
    videoUrl,
    coverImage,
    images,
    latitude,
    longitude,
    rating,
    reviewsCount,
    offers,
    createdAt,
    updatedAt,
  ];
}
