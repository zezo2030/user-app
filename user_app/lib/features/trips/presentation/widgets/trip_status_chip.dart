import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/trip_request_status.dart';

class TripStatusChip extends StatelessWidget {
  const TripStatusChip({super.key, required this.status});

  final TripRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _StatusColors _statusColors(BuildContext context, TripRequestStatus status) {
    final theme = Theme.of(context);
    switch (status) {
      case TripRequestStatus.pending:
        return _StatusColors(
          background: theme.colorScheme.secondaryContainer,
          foreground: theme.colorScheme.onSecondaryContainer,
        );
      case TripRequestStatus.underReview:
        return _StatusColors(
          background: theme.colorScheme.surfaceContainerHighest,
          foreground: theme.colorScheme.onSurfaceVariant,
        );
      case TripRequestStatus.approved:
        return _StatusColors(
          background: Colors.green.withOpacity(0.15),
          foreground: Colors.green.shade700,
        );
      case TripRequestStatus.rejected:
      case TripRequestStatus.cancelled:
        return _StatusColors(
          background: Colors.red.withOpacity(0.15),
          foreground: Colors.red.shade700,
        );
      case TripRequestStatus.invoiced:
        return _StatusColors(
          background: Colors.blue.withOpacity(0.15),
          foreground: Colors.blue.shade700,
        );
      case TripRequestStatus.paid:
        return _StatusColors(
          background: Colors.teal.withOpacity(0.15),
          foreground: Colors.teal.shade700,
        );
      case TripRequestStatus.completed:
        return _StatusColors(
          background: theme.colorScheme.primaryContainer,
          foreground: theme.colorScheme.onPrimaryContainer,
        );
      case TripRequestStatus.unknown:
        return _StatusColors(
          background: theme.colorScheme.surfaceContainerHighest,
          foreground: theme.colorScheme.onSurfaceVariant,
        );
    }
  }

  String _statusLabel(TripRequestStatus status) {
    switch (status) {
      case TripRequestStatus.pending:
        return tr('status_pending');
      case TripRequestStatus.underReview:
        return tr('status_under_review');
      case TripRequestStatus.approved:
        return tr('status_approved');
      case TripRequestStatus.rejected:
        return tr('status_rejected');
      case TripRequestStatus.invoiced:
        return tr('status_invoiced');
      case TripRequestStatus.paid:
        return tr('status_paid');
      case TripRequestStatus.completed:
        return tr('status_completed');
      case TripRequestStatus.cancelled:
        return tr('status_cancelled');
      case TripRequestStatus.unknown:
        return tr('status_unknown');
    }
  }
}

class _StatusColors {
  const _StatusColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
