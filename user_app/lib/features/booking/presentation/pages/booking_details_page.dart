// Booking Details Page - Presentation Layer
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/booking_entity.dart';
import '../widgets/price_breakdown_card.dart';
import '../../domain/entities/quote_entity.dart';

class BookingDetailsPage extends StatelessWidget {
  final BookingEntity booking;
  final QuoteEntity? quote; // للعرض التفصيلي للسعر

  const BookingDetailsPage({super.key, required this.booking, this.quote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('booking_details'.tr()),
        centerTitle: true,
        actions: [
          // زر المشاركة
          IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: () {
              // TODO: تنفيذ مشاركة تفاصيل الحجز
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الحجز الأساسية
            _buildBookingInfoCard(context),
            const SizedBox(height: 16),

            // حالة الحجز
            _buildStatusCard(context),
            const SizedBox(height: 16),

            // تفاصيل التسعير
            if (quote != null) ...[
              PriceBreakdownCard(
                quote: quote,
                durationHours: booking.durationHours,
              ),
              const SizedBox(height: 16),
            ],

            // معلومات إضافية
            _buildAdditionalInfoCard(context),
            const SizedBox(height: 16),

            // أزرار الإجراءات
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.calendar, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'booking_information'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // اسم القاعة
            _buildInfoRow(
              context,
              'hall'.tr(),
              'Hall Name', // TODO: إضافة اسم القاعة من البيانات
              Iconsax.home_2,
            ),
            const SizedBox(height: 8),

            // التاريخ والوقت
            _buildInfoRow(
              context,
              'date_time'.tr(),
              DateFormat('yyyy-MM-dd HH:mm').format(booking.startTime),
              Iconsax.calendar,
            ),
            const SizedBox(height: 8),

            // المدة
            _buildInfoRow(
              context,
              'duration'.tr(),
              '${booking.durationHours} ${'hours'.tr()}',
              Iconsax.timer,
            ),
            const SizedBox(height: 8),

            // عدد الأشخاص
            _buildInfoRow(
              context,
              'number_of_persons'.tr(),
              '${booking.persons} ${'persons'.tr()}',
              Iconsax.people,
            ),
            const SizedBox(height: 8),

            // السعر الإجمالي
            _buildInfoRow(
              context,
              'total_price'.tr(),
              '${booking.totalPrice.toStringAsFixed(2)} ${'currency'.tr()}',
              Iconsax.dollar_circle,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (booking.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Iconsax.clock;
        statusText = 'pending'.tr();
        break;
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Iconsax.tick_circle;
        statusText = 'confirmed'.tr();
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Iconsax.close_circle;
        statusText = 'cancelled'.tr();
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Iconsax.info_circle;
        statusText = booking.status;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'booking_status'.tr(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (booking.status.toLowerCase() == 'cancelled' &&
                booking.cancellationReason != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Iconsax.info_circle, color: Colors.grey.shade600),
                onPressed: () {
                  _showCancellationReason(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.document_text, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                Text(
                  'additional_information'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // كود الخصم
            if (booking.couponCode != null) ...[
              _buildInfoRow(
                context,
                'coupon_code'.tr(),
                booking.couponCode!,
                Iconsax.discount_shape,
                color: Colors.green,
              ),
              const SizedBox(height: 8),
            ],

            // مبلغ الخصم
            if (booking.discountAmount != null &&
                booking.discountAmount! > 0) ...[
              _buildInfoRow(
                context,
                'discount_amount'.tr(),
                '${booking.discountAmount!.toStringAsFixed(2)} ${'currency'.tr()}',
                Iconsax.discount_shape,
                color: Colors.green,
              ),
              const SizedBox(height: 8),
            ],

            // الطلبات الخاصة
            if (booking.specialRequests != null &&
                booking.specialRequests!.isNotEmpty) ...[
              _buildInfoRow(
                context,
                'special_requests'.tr(),
                booking.specialRequests!,
                Iconsax.message_text,
              ),
              const SizedBox(height: 8),
            ],

            // رقم الهاتف
            if (booking.contactPhone != null &&
                booking.contactPhone!.isNotEmpty) ...[
              _buildInfoRow(
                context,
                'contact_phone'.tr(),
                booking.contactPhone!,
                Iconsax.call,
              ),
              const SizedBox(height: 8),
            ],

            // تاريخ الإنشاء
            _buildInfoRow(
              context,
              'created_at'.tr(),
              DateFormat('yyyy-MM-dd HH:mm').format(booking.createdAt),
              Iconsax.calendar_1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // زر الإلغاء (إذا كان الحجز قابل للإلغاء)
        if (booking.status.toLowerCase() == 'pending') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showCancelBookingDialog(context);
              },
              icon: const Icon(Iconsax.close_circle),
              label: Text('cancel_booking'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // زر العودة
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Iconsax.arrow_left),
            label: Text('back'.tr()),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
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
        Expanded(
          child: Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color ?? Colors.grey.shade700,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _showCancellationReason(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('cancellation_reason'.tr()),
        content: Text(booking.cancellationReason ?? 'no_reason_provided'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  void _showCancelBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('cancel_booking'.tr()),
        content: Text('cancel_booking_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('no'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: تنفيذ إلغاء الحجز
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('booking_cancelled'.tr()),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('yes'.tr()),
          ),
        ],
      ),
    );
  }
}
