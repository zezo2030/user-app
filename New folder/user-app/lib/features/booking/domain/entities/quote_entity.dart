// Quote Entity - Domain Layer
import 'package:equatable/equatable.dart';

class QuoteEntity extends Equatable {
  final String hallId;
  final String hallName;
  final Map<String, dynamic> pricing;
  final List<Map<String, dynamic>> addOns;
  final double discount;
  final double totalPrice;
  final bool available;

  const QuoteEntity({
    required this.hallId,
    required this.hallName,
    required this.pricing,
    required this.addOns,
    required this.discount,
    required this.totalPrice,
    required this.available,
  });

  @override
  List<Object?> get props => [
        hallId,
        hallName,
        pricing,
        addOns,
        discount,
        totalPrice,
        available,
      ];
}

