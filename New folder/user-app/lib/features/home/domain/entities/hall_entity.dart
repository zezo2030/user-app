import 'package:equatable/equatable.dart';

class HallEntity extends Equatable {
  final String id;
  final String branchId;
  final String nameAr;
  final String nameEn;
  final int capacity;
  final String status; // 'available', 'maintenance', 'reserved'
  final Map<String, dynamic> priceConfig;
  final bool isDecorated;
  final String? descriptionAr;
  final String? descriptionEn;
  final List<String>? features;
  final List<String>? images;
  final String? videoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HallEntity({
    required this.id,
    required this.branchId,
    required this.nameAr,
    required this.nameEn,
    required this.capacity,
    required this.status,
    required this.priceConfig,
    required this.isDecorated,
    this.descriptionAr,
    this.descriptionEn,
    this.features,
    this.images,
    this.videoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        branchId,
        nameAr,
        nameEn,
        capacity,
        status,
        priceConfig,
        isDecorated,
        descriptionAr,
        descriptionEn,
        features,
        images,
        videoUrl,
        createdAt,
        updatedAt,
      ];
}
