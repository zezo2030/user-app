import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/hall_entity.dart';

part 'hall_model.g.dart';

@JsonSerializable()
class HallModel extends HallEntity {
  const HallModel({
    required super.id,
    required super.branchId,
    required super.nameAr,
    required super.nameEn,
    required super.capacity,
    required super.status,
    required super.priceConfig,
    required super.isDecorated,
    super.descriptionAr,
    super.descriptionEn,
    super.features,
    super.images,
    required super.createdAt,
    required super.updatedAt,
  });

  factory HallModel.fromJson(Map<String, dynamic> json) {
    return HallModel(
      id: json['id']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      capacity: json['capacity'] is int 
          ? json['capacity'] as int
          : int.tryParse(json['capacity']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'available',
      priceConfig: json['priceConfig'] is Map<String, dynamic>
          ? json['priceConfig'] as Map<String, dynamic>
          : <String, dynamic>{},
      isDecorated: json['isDecorated'] is bool
          ? json['isDecorated'] as bool
          : json['isDecorated']?.toString().toLowerCase() == 'true',
      descriptionAr: json['description_ar']?.toString(),
      descriptionEn: json['description_en']?.toString(),
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e?.toString() ?? '')
          .toList(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e?.toString() ?? '')
          .toList(),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$HallModelToJson(this);

  factory HallModel.fromEntity(HallEntity entity) {
    return HallModel(
      id: entity.id,
      branchId: entity.branchId,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      capacity: entity.capacity,
      status: entity.status,
      priceConfig: entity.priceConfig,
      isDecorated: entity.isDecorated,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      features: entity.features,
      images: entity.images,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  HallEntity toEntity() {
    return HallEntity(
      id: id,
      branchId: branchId,
      nameAr: nameAr,
      nameEn: nameEn,
      capacity: capacity,
      status: status,
      priceConfig: priceConfig,
      isDecorated: isDecorated,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      features: features,
      images: images,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
