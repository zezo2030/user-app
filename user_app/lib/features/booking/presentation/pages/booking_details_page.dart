// Booking Details Page - Presentation Layer
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../payments/presentation/cubit/payment_cubit.dart';
import '../../../payments/di/payments_injection.dart' as payments_di;
import '../../domain/entities/booking_entity.dart';
import '../widgets/price_breakdown_card.dart';
import '../../domain/entities/quote_entity.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../tickets/data/datasources/tickets_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';
import '../../../tickets/data/models/ticket_model.dart';

class BookingDetailsPage extends StatelessWidget {
  final BookingEntity booking;
  final QuoteEntity? quote; // للعرض التفصيلي للسعر
  final Set<String>? filterTicketIds; // لتقييد العرض بمعرفات تذاكر محددة

  const BookingDetailsPage({
    super.key,
    required this.booking,
    this.quote,
    this.filterTicketIds,
  });

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

            // التذاكر الخاصة بهذا الحجز فقط
            _buildTicketsSection(context),
            const SizedBox(height: 16),

            // أزرار الإجراءات
            _buildActionButtons(context),
            const SizedBox(height: 16),

            // إظهار ملاحظة عدم إتاحة التذاكر قبل الدفع
            if (booking.status.toLowerCase() == 'pending')
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Iconsax.info_circle, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'complete_payment_to_view_tickets'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
        // لم نعد ننتقل لصفحة عامة؛ نعرض التذاكر هنا مباشرة
        // زر الإلغاء (إذا كان الحجز قابل للإلغاء)
        if (booking.status.toLowerCase() == 'pending') ...[
          // زر الدفع الآن
          SizedBox(
            width: double.infinity,
            child: BlocProvider(
              create: (_) {
                // Ensure payments DI is initialized once
                try {
                  payments_di.initPayments();
                } catch (_) {}
                return payments_di.sl<PaymentCubit>();
              },
              child: BlocConsumer<PaymentCubit, PaymentState>(
                listener: (context, state) {
                  if (state is PaymentSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('payment_success'.tr()),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // بعد الدفع، يمكننا إعادة بناء تذاكر نفس الحجز في الصفحة
                    // أو إظهار رسالة نجاح فقط
                  } else if (state is PaymentFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is PaymentLoading;
                  return ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => context.read<PaymentCubit>().payForBooking(
                            booking: booking,
                          ),
                    icon: const Icon(Iconsax.card),
                    label: Text(isLoading ? 'processing'.tr() : 'pay_now'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
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

  Widget _buildTicketsSection(BuildContext context) {
    // عرض تذاكر هذا الحجز فقط
    final ds = TicketsRemoteDataSourceImpl(dio: DioClient.instance);
    final Future<List<TicketModel>> ticketsFuture = ds.getBookingTickets(
      booking.id,
    );

    if (booking.status.toLowerCase() == 'pending') {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.ticket, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'tickets'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<TicketModel>>(
              future: ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                final tickets = snapshot.data ?? const <TicketModel>[];

                // Filter tickets strictly by provided ticket IDs (if any)
                List<TicketModel> myTickets;
                if (filterTicketIds != null && filterTicketIds!.isNotEmpty) {
                  myTickets = tickets
                      .where((t) => filterTicketIds!.contains(t.id))
                      .toList();
                } else {
                  myTickets = tickets; // عرض كل تذاكر الحجز افتراضيًا
                }

                if (myTickets.isEmpty) {
                  return Text('no_tickets'.tr());
                }
                final countText = '${'tickets'.tr()} (${myTickets.length})';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        countText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: myTickets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final t = myTickets[index];
                        Color statusColor;
                        switch (t.status.toLowerCase()) {
                          case 'valid':
                            statusColor = Colors.green;
                            break;
                          case 'used':
                            statusColor = Colors.blueGrey;
                            break;
                          case 'expired':
                            statusColor = Colors.orange;
                            break;
                          case 'cancelled':
                            statusColor = Colors.red;
                            break;
                          default:
                            statusColor = Colors.grey;
                        }
                        return InkWell(
                          onTap: () async {
                            final qr = await ds.getTicketQr(t.id);
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('QR'),
                                      const SizedBox(height: 12),
                                      _buildQrWidget(qr),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Text(
                                          t.status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '#${index + 1}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // عنصر بسيط لعرض QR إما Data URL صورة أو نص
  // يستخدم محليًا لعرض QR ضمن تفاصيل الحجز
  Widget _buildQrWidget(String data) {
    if (data.startsWith('data:image')) {
      try {
        final payload = data.split(',').last;
        return Image.memory(
          base64Decode(payload),
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        );
      } catch (_) {
        return SelectableText(data);
      }
    }
    return SelectableText(data);
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
