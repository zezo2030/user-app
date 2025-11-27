// Event Request Details Page - Presentation Layer
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../auth/di/auth_injection.dart';
import '../../domain/entities/event_request_entity.dart';
import '../cubit/event_request_cubit.dart';
import '../cubit/event_request_state.dart';
import '../widgets/event_request_status_badge.dart';

class _EventRequestDetailsHelper {
  static String getEventTypeTranslation(String type) {
    switch (type) {
      case 'birthday':
        return 'event_type_birthday'.tr();
      case 'graduation':
        return 'event_type_graduation'.tr();
      case 'family':
        return 'event_type_family'.tr();
      case 'corporate':
        return 'event_type_corporate'.tr();
      case 'wedding':
        return 'event_type_wedding'.tr();
      case 'other':
        return 'event_type_other'.tr();
      default:
        return type;
    }
  }
}

class EventRequestDetailsPage extends StatelessWidget {
  final String requestId;

  const EventRequestDetailsPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EventRequestCubit>()..getRequest(requestId),
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: BlocBuilder<EventRequestCubit, EventRequestState>(
          builder: (context, state) {
            if (state is EventRequestDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is EventRequestDetailError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<EventRequestCubit>().getRequest(requestId);
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is EventRequestDetailLoaded) {
              return _buildDetails(context, state.request);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, EventRequestEntity request) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الحالة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  EventRequestStatusBadge(status: request.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Basic Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.information,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'معلومات الطلب',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    'event_type'.tr(),
                    _EventRequestDetailsHelper.getEventTypeTranslation(
                      request.type,
                    ),
                    Iconsax.calendar,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    'التاريخ والوقت',
                    dateFormat.format(request.startTime.toLocal()),
                    Iconsax.calendar_1,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    'المدة',
                    '${request.durationHours} ساعة',
                    Iconsax.timer,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    'عدد الأشخاص',
                    '${request.persons} شخص',
                    Iconsax.people,
                  ),
                  if (request.hallId != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      'الصالة',
                      request.hallId!,
                      Iconsax.home,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    'الديكور',
                    request.decorated ? 'نعم' : 'لا',
                    Iconsax.magic_star,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Price Card (if quoted)
          if (request.quotedPrice != null)
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Iconsax.money_recive, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'السعر المقترح',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${request.quotedPrice!.toStringAsFixed(2)} ريال',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (request.quotedPrice != null) const SizedBox(height: 16),

          // Notes Card (if exists)
          if (request.notes != null && request.notes!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.note, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'ملاحظات',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(request.notes!),
                  ],
                ),
              ),
            ),
          if (request.notes != null && request.notes!.isNotEmpty)
            const SizedBox(height: 16),

          // Add-ons Card (if exists)
          if (request.addOns != null && request.addOns!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.box, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'الإضافات',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...request.addOns!.map((addon) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${addon['name'] ?? ''} (${addon['quantity'] ?? 1}x)',
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
