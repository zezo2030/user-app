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

    double _readNum(
      Map<String, dynamic> map,
      List<String> keys, {
      double defaultValue = 0.0,
    }) {
      for (final k in keys) {
        if (map.containsKey(k) && map[k] != null) {
          final v = map[k];
          if (v is num) return v.toDouble();
          if (v is String) {
            final parsed = double.tryParse(v);
            if (parsed != null) return parsed;
          }
        }
      }
      return defaultValue;
    }

    // استخراج جميع حقول التسعير من الباك إند مع دعم مفاتيح بديلة
    final processedPricing = <String, dynamic>{
      'basePrice': _readNum(pricing, ['basePrice', 'base_price', 'base']),
      'hourlyPrice': _readNum(pricing, [
        'hourlyPrice',
        'hourly_price',
        'totalHourly',
        'hoursTotal',
      ]),
      'hourlyRate': _readNum(pricing, [
        'hourlyRate',
        'hourly_rate',
        'perHour',
        'per_hour',
        'hour_rate',
      ]),
      'pricePerPerson': _readNum(pricing, [
        'pricePerPerson',
        'price_per_person',
        'perPerson',
        'per_person',
      ]),
      'personsPrice': _readNum(pricing, [
        'personsPrice',
        'persons_price',
        'peopleTotal',
        'persons_total',
      ]),
      'multiplier': _readNum(pricing, [
        'multiplier',
        'dayMultiplier',
        'factor',
      ], defaultValue: 1.0),
      'decorationPrice': _readNum(pricing, [
        'decorationPrice',
        'decoration_price',
        'decorPrice',
        'decor_price',
      ]),
      'totalPrice': _readNum(pricing, [
        'totalPrice',
        'total_price',
        'grandTotal',
      ]),
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
