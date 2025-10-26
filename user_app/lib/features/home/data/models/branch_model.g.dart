// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchModel _$BranchModelFromJson(Map<String, dynamic> json) => BranchModel(
  id: json['id'] as String,
  nameAr: json['nameAr'] as String,
  nameEn: json['nameEn'] as String,
  location: json['location'] as String,
  capacity: (json['capacity'] as num).toInt(),
  status: json['status'] as String,
  descriptionAr: json['descriptionAr'] as String?,
  descriptionEn: json['descriptionEn'] as String?,
  contactPhone: json['contactPhone'] as String?,
  workingHours: json['workingHours'] as Map<String, dynamic>?,
  amenities: (json['amenities'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  videoUrl: json['videoUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BranchModelToJson(BranchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameAr': instance.nameAr,
      'nameEn': instance.nameEn,
      'location': instance.location,
      'capacity': instance.capacity,
      'status': instance.status,
      'descriptionAr': instance.descriptionAr,
      'descriptionEn': instance.descriptionEn,
      'contactPhone': instance.contactPhone,
      'workingHours': instance.workingHours,
      'amenities': instance.amenities,
      'videoUrl': instance.videoUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
