// Booking Summary Card Widget - Presentation Layer
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/quote_entity.dart';

class BookingSummaryCard extends StatelessWidget {
  final String hallName;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final int durationHours;
  final int personsCount;
  final QuoteEntity? quote;
  final String? couponCode;
  final List<Map<String, dynamic>>? selectedAddOns;
  final String? specialRequests;
  final String? contactPhone;

  const BookingSummaryCard({
    Key? key,
    required this.hallName,
    required this.selectedDate,
    required this.selectedTime,
    required this.durationHours,
    required this.personsCount,
    this.quote,
    this.couponCode,
    this.selectedAddOns,
    this.specialRequests,
    this.contactPhone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.document_text, size: 20),
                const SizedBox(width: 8),
                Text(
                  'booking_summary'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(context, 'hall'.tr(), hallName, Iconsax.home_2),
            const SizedBox(height: 8),
            _buildSummaryItem(
              context,
              'date'.tr(),
              selectedDate != null
                  ? DateFormat('yyyy/MM/dd').format(selectedDate!)
                  : 'not_selected'.tr(),
              Iconsax.calendar_1,
            ),
            const SizedBox(height: 8),
            _buildSummaryItem(
              context,
              'time'.tr(),
              selectedTime != null
                  ? selectedTime!.format(context)
                  : 'not_selected'.tr(),
              Iconsax.clock,
            ),
            const SizedBox(height: 8),
            _buildSummaryItem(
              context,
              'duration'.tr(),
              '$durationHours ${'hours'.tr()}',
              Iconsax.timer,
            ),
            const SizedBox(height: 8),
            _buildSummaryItem(
              context,
              'persons'.tr(),
              '$personsCount ${'persons'.tr()}',
              Iconsax.people,
            ),
            if (couponCode != null) ...[
              const SizedBox(height: 8),
              _buildSummaryItem(
                context,
                'coupon_code'.tr(),
                couponCode!,
                Iconsax.discount_shape,
                color: Colors.green,
              ),
            ],
            if (selectedAddOns != null && selectedAddOns!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildSummaryItem(
                context,
                'add_ons'.tr(),
                '${selectedAddOns!.length} ${'items'.tr()}',
                Iconsax.add_square,
              ),
            ],
            if (specialRequests != null && specialRequests!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildSummaryItem(
                context,
                'special_requests'.tr(),
                specialRequests!,
                Iconsax.note_text,
              ),
            ],
            if (contactPhone != null) ...[
              const SizedBox(height: 8),
              _buildSummaryItem(
                context,
                'contact_phone'.tr(),
                contactPhone!,
                Iconsax.call,
              ),
            ],
            if (quote != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildPriceSummary(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color ?? Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'price_summary'.tr(),
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildPriceRow(
          context,
          'base_price'.tr(),
          '${_getBasePrice()} ${'currency'.tr()}',
        ),
        if (quote!.discount > 0) ...[
          _buildPriceRow(
            context,
            'discount'.tr(),
            '-${quote!.discount.toStringAsFixed(2)} ${'currency'.tr()}',
            color: Colors.green,
          ),
        ],
        const Divider(),
        _buildPriceRow(
          context,
          'total_price'.tr(),
          '${quote!.totalPrice.toStringAsFixed(2)} ${'currency'.tr()}',
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // دالة للحصول على السعر الأساسي
  String _getBasePrice() {
    if (quote == null) return '0';

    // أولاً نحاول الحصول على السعر الأساسي من البيانات المرسلة
    final basePrice = quote!.pricing['basePrice'];
    if (basePrice != null && basePrice != 0) {
      return basePrice.toString();
    }

    // إذا لم يكن هناك سعر أساسي، نستخدم السعر الإجمالي
    if (quote!.totalPrice > 0) {
      return quote!.totalPrice.toStringAsFixed(2);
    }

    return '0';
  }
}
