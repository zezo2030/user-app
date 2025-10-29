import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/offer_entity.dart';

part 'offer_model.g.dart';

@JsonSerializable()
class OfferModel extends OfferEntity {
  const OfferModel({
    required super.id,
    required super.title,
    super.description,
    required super.discountType,
    required super.discountValue,
    super.startsAt,
    super.endsAt,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.imageUrl,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    // معالجة مخصصة لـ discountValue لتجنب خطأ تحويل النوع
    double parsedDiscountValue = 0.0;
    final discountValue = json['discountValue'];

    if (discountValue != null) {
      if (discountValue is num) {
        parsedDiscountValue = discountValue.toDouble();
      } else if (discountValue is String) {
        parsedDiscountValue = double.tryParse(discountValue) ?? 0.0;
      }
    }

    return OfferModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      discountType: json['discountType']?.toString() ?? 'percentage',
      discountValue: parsedDiscountValue,
      startsAt: json['startsAt'] != null
          ? DateTime.tryParse(json['startsAt'].toString())
          : null,
      endsAt: json['endsAt'] != null
          ? DateTime.tryParse(json['endsAt'].toString())
          : null,
      isActive: json['isActive'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => _$OfferModelToJson(this);

  factory OfferModel.fromEntity(OfferEntity entity) {
    return OfferModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      discountType: entity.discountType,
      discountValue: entity.discountValue,
      startsAt: entity.startsAt,
      endsAt: entity.endsAt,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      imageUrl: entity.imageUrl,
    );
  }

  OfferEntity toEntity() {
    return OfferEntity(
      id: id,
      title: title,
      description: description,
      discountType: discountType,
      discountValue: discountValue,
      startsAt: startsAt,
      endsAt: endsAt,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      imageUrl: imageUrl,
    );
  }
}
