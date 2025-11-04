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
import 'package:share_plus/share_plus.dart';
import '../../../tickets/data/datasources/tickets_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';
import '../../../tickets/data/models/ticket_model.dart';
import 'package:dio/dio.dart';
import '../../../activities/data/bookings_api.dart';
import '../widgets/ticket_card.dart';
import '../../../../core/utils/share_utils.dart';
// removed duplicate import

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
            onPressed: () async {
              // مشاركة مختصرة لتفاصيل الحجز
              final msg =
                  '${'booking_details'.tr()} - ${'hall'.tr()}: ${'hall'.tr()} | ${'date_time'.tr()}: ${DateFormat('yyyy-MM-dd HH:mm').format(booking.startTime)} | ${'duration'.tr()}: ${booking.durationHours} ${'hours'.tr()}';
              try {
                await Share.share(msg);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('unknown_error'.tr())));
              }
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
              'hall'.tr(), // TODO: إضافة اسم القاعة من البيانات
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
                final now = DateTime.now();
                final hoursUntil = booking.startTime.difference(now).inHours;
                if (hoursUntil < 24) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        // رسالة عربية واضحة لحالة أقل من 24 ساعة
                        'لا يمكن إلغاء الحجز قبل 24 ساعة من موعده',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
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
                  // Skeleton بسيط
                  return Column(
                    children: List.generate(
                      3,
                      (_) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
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
                  return Column(
                    children: [
                      const SizedBox(height: 8),
                      Icon(
                        Iconsax.ticket,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'no_tickets'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  );
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
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final t = myTickets[index];
                        return TicketCard(
                          id: t.id,
                          status: t.status,
                          onViewQr: () async {
                            final qr = await ds.getTicketQr(t.id);
                            if (!context.mounted) return;
                            _showQrBottomSheet(context, qr, t.id);
                          },
                          onCopyId: () async {
                            await Clipboard.setData(ClipboardData(text: t.id));
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('copied'.tr())),
                            );
                          },
                          onShare: () async {
                            try {
                              HapticFeedback.selectionClick();
                              final qr = await ds.getTicketQr(t.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('share'.tr())),
                              );
                              await shareTicketQrPreferWhatsApp(
                                context: context,
                                ticketId: t.id,
                                qrData: qr,
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('unknown_error'.tr())),
                              );
                            }
                          },
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

  void _showQrBottomSheet(
    BuildContext context,
    String qrData,
    String ticketId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.scan_barcode),
                  const SizedBox(width: 8),
                  Text(
                    'qr_code'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(child: _buildQrWidget(qrData)),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: ticketId));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('copied'.tr())));
                    },
                    icon: const Icon(Iconsax.copy),
                    label: Text('copy_ticket_id'.tr()),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        HapticFeedback.selectionClick();
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('share'.tr())));
                        await shareTicketQrPreferWhatsApp(
                          context: context,
                          ticketId: ticketId,
                          qrData: qrData,
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('unknown_error'.tr())),
                        );
                      }
                    },
                    icon: const Icon(Iconsax.export_1),
                    label: Text('share'.tr()),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'لا تشارك رمز الـ QR إلا مع الشخص المخوّل باستخدام التذكرة',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      },
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
            onPressed: () async {
              Navigator.pop(context);
              // مؤشر انتظار
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
              try {
                await BookingsApi().cancelBooking(id: booking.id);
                if (!context.mounted) return;
                Navigator.pop(context); // اغلاق مؤشر الانتظار
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('booking_cancelled'.tr()),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true); // عودة مع نتيجة للتحديث
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context); // اغلاق مؤشر الانتظار
                String message = e.toString();
                if (e is DioException) {
                  final data = e.response?.data;
                  if (data is Map && data['message'] is String) {
                    final serverMsg = data['message'] as String;
                    if (serverMsg.contains('24 hours')) {
                      message = 'لا يمكن إلغاء الحجز قبل 24 ساعة من موعده';
                    } else {
                      message = serverMsg;
                    }
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message), backgroundColor: Colors.red),
                );
              }
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
