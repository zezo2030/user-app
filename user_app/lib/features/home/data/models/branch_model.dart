import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/branch_entity.dart';

part 'branch_model.g.dart';

@JsonSerializable()
class BranchModel extends BranchEntity {
  const BranchModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.location,
    required super.capacity,
    required super.status,
    super.descriptionAr,
    super.descriptionEn,
    super.contactPhone,
    super.workingHours,
    super.amenities,
    super.videoUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    // التحقق من وجود السعة ومعالجتها بشكل صحيح
    final capacity = json['capacity'];
    int parsedCapacity = 0;
    
    if (capacity != null) {
      if (capacity is int) {
        parsedCapacity = capacity;
      } else if (capacity is double) {
        parsedCapacity = capacity.toInt();
      } else if (capacity is String) {
        final cleanValue = capacity.trim().replaceAll(RegExp(r'[^\d]'), '');
        parsedCapacity = int.tryParse(cleanValue) ?? 0;
      }
    }
    
    return BranchModel(
      id: json['id']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      capacity: parsedCapacity,
      status: json['status']?.toString() ?? 'inactive',
      descriptionAr: json['description_ar']?.toString(),
      descriptionEn: json['description_en']?.toString(),
      contactPhone: json['contactPhone']?.toString(),
      workingHours: json['workingHours'] as Map<String, dynamic>?,
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e?.toString() ?? '')
          .toList(),
      videoUrl: json['videoUrl']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$BranchModelToJson(this);

  factory BranchModel.fromEntity(BranchEntity entity) {
    return BranchModel(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      location: entity.location,
      capacity: entity.capacity,
      status: entity.status,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      contactPhone: entity.contactPhone,
      workingHours: entity.workingHours,
      amenities: entity.amenities,
      videoUrl: entity.videoUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  BranchEntity toEntity() {
    return BranchEntity(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      location: location,
      capacity: capacity,
      status: status,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      contactPhone: contactPhone,
      workingHours: workingHours,
      amenities: amenities,
      videoUrl: videoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
