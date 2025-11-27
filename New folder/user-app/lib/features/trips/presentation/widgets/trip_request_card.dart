import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/school_trip_request_entity.dart';
import 'trip_status_chip.dart';

class TripRequestCard extends StatelessWidget {
  const TripRequestCard({
    super.key,
    required this.request,
    this.onTap,
  });

  final SchoolTripRequestEntity request;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalParticipants =
        request.studentsCount + request.accompanyingAdults;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.schoolName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TripStatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tr('trip_request_id', args: [request.id.substring(0, 8)]),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 18, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  DateFormat.yMMMMd(context.locale.toString())
                      .format(request.preferredDate),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people_outline,
                    size: 18, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  tr(
                    'trip_participants_count',
                    args: [
                      request.studentsCount.toString(),
                      request.accompanyingAdults.toString(),
                      totalParticipants.toString(),
                    ],
                  ),
                ),
              ],
            ),
            if (request.quotedPrice != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.payments_outlined,
                      size: 18, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    tr(
                      'trip_quoted_price',
                      args: [request.quotedPrice!.toStringAsFixed(2)],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

