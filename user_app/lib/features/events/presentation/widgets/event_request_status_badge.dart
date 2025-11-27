// Event Request Status Badge - Presentation Widget
import 'package:flutter/material.dart';
import '../../domain/entities/event_request_status.dart';

class EventRequestStatusBadge extends StatelessWidget {
  final EventRequestStatus status;

  const EventRequestStatusBadge({
    super.key,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case EventRequestStatus.draft:
        return Colors.grey;
      case EventRequestStatus.submitted:
        return Colors.blue;
      case EventRequestStatus.underReview:
        return Colors.orange;
      case EventRequestStatus.quoted:
        return Colors.purple;
      case EventRequestStatus.invoiced:
        return Colors.indigo;
      case EventRequestStatus.paid:
        return Colors.green;
      case EventRequestStatus.confirmed:
        return Colors.teal;
      case EventRequestStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        status.getDisplayName(),
        style: TextStyle(
          color: _statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

