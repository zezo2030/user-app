// Quote Model - Data Layer
import '../../domain/entities/quote_entity.dart';

class QuoteModel extends QuoteEntity {
  const QuoteModel({
    required super.hallId,
    required super.hallName,
    required super.pricing,
    required super.addOns,
    required super.discount,
    required super.totalPrice,
    required super.available,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    // معالجة بيانات التسعير من الباك إند
    final pricing = json['pricing'] as Map<String, dynamic>? ?? {};

    // استخراج جميع حقول التسعير من الباك إند
    final processedPricing = <String, dynamic>{
      'basePrice': pricing['basePrice'] != null
          ? (pricing['basePrice'] as num).toDouble()
          : 0.0,
      'hourlyPrice': pricing['hourlyPrice'] != null
          ? (pricing['hourlyPrice'] as num).toDouble()
          : 0.0,
      'hourlyRate': pricing['hourlyRate'] != null
          ? (pricing['hourlyRate'] as num).toDouble()
          : 0.0,
      'multiplier': pricing['multiplier'] != null
          ? (pricing['multiplier'] as num).toDouble()
          : 1.0,
      'decorationPrice': pricing['decorationPrice'] != null
          ? (pricing['decorationPrice'] as num).toDouble()
          : 0.0,
      'totalPrice': pricing['totalPrice'] != null
          ? (pricing['totalPrice'] as num).toDouble()
          : 0.0,
    };

    // معلومات تشخيصية للتحقق من البيانات
    print('🔍 QuoteModel: Processing pricing data from backend');
    print('🔍 QuoteModel: Raw pricing: $pricing');
    print('🔍 QuoteModel: Processed pricing: $processedPricing');
    print('🔍 QuoteModel: Total price: ${json['totalPrice']}');
    print('🔍 QuoteModel: AddOns count: ${json['addOns']?.length ?? 0}');
    print('🔍 QuoteModel: Discount: ${json['discount']}');
    print('🔍 QuoteModel: Available: ${json['available']}');

    return QuoteModel(
      hallId: json['hallId'] as String,
      hallName: json['hallName'] as String,
      pricing: processedPricing,
      addOns: List<Map<String, dynamic>>.from(json['addOns'] ?? []),
      discount: (json['discount'] as num? ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] as num? ?? 0).toDouble(),
      available: json['available'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hallId': hallId,
      'hallName': hallName,
      'pricing': pricing,
      'addOns': addOns,
      'discount': discount,
      'totalPrice': totalPrice,
      'available': available,
    };
  }
}
