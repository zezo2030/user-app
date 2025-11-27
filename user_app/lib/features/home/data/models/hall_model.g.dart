// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hall_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HallModel _$HallModelFromJson(Map<String, dynamic> json) => HallModel(
      id: json['id'] as String,
      branchId: json['branchId'] as String,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      capacity: (json['capacity'] as num).toInt(),
      status: json['status'] as String,
      priceConfig: json['priceConfig'] as Map<String, dynamic>,
      isDecorated: json['isDecorated'] as bool,
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      videoUrl: json['videoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$HallModelToJson(HallModel instance) => <String, dynamic>{
      'id': instance.id,
      'branchId': instance.branchId,
      'nameAr': instance.nameAr,
      'nameEn': instance.nameEn,
      'capacity': instance.capacity,
      'status': instance.status,
      'priceConfig': instance.priceConfig,
      'isDecorated': instance.isDecorated,
      'descriptionAr': instance.descriptionAr,
      'descriptionEn': instance.descriptionEn,
      'features': instance.features,
      'images': instance.images,
      'videoUrl': instance.videoUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
