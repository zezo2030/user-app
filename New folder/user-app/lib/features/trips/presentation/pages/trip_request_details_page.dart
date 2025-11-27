import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/trips_injection.dart' as trips_di;
import '../../domain/entities/school_trip_request_entity.dart';
import '../../domain/entities/trip_request_status.dart';
import '../cubit/trip_request_details_cubit.dart';
import '../cubit/trip_request_details_state.dart';
import '../widgets/trip_status_chip.dart';

class TripRequestDetailsPage extends StatefulWidget {
  const TripRequestDetailsPage({
    super.key,
    required this.requestId,
    this.initialRequest,
  });

  final String requestId;
  final SchoolTripRequestEntity? initialRequest;

  @override
  State<TripRequestDetailsPage> createState() => _TripRequestDetailsPageState();
}

class _TripRequestDetailsPageState extends State<TripRequestDetailsPage> {
  late final TripRequestDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = trips_di.sl<TripRequestDetailsCubit>();
    _cubit.load(widget.requestId, optimisticRequest: widget.initialRequest);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('trip_request_details_title'.tr()),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _cubit.load(widget.requestId),
            ),
          ],
        ),
        body: BlocConsumer<TripRequestDetailsCubit, TripRequestDetailsState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            } else if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading && !state.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final request = state.request;
            if (request == null) {
              return Center(
                child: Text('trip_request_not_found'.tr()),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _cubit.load(widget.requestId),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _HeaderSection(request: request),
                  const SizedBox(height: 16),
                  _InfoSection(request: request),
                  const SizedBox(height: 16),
                  _ParticipantsSection(request: request),
                  const SizedBox(height: 16),
                  _AddOnsSection(request: request),
                  const SizedBox(height: 16),
                  _StatusTimelineSection(request: request),
                  const SizedBox(height: 24),
                  _ActionsSection(
                    request: request,
                    isSubmitting: state.isSubmitting,
                    isUploading: state.isUploading,
                    onSubmit: () => _cubit.submitRequest(widget.requestId),
                    onUpload: _handleFileUpload,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleFileUpload() async {
    final pickResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'xls', 'csv'],
      withData: true,
    );
    if (pickResult == null || pickResult.files.isEmpty) {
      return;
    }

    final file = pickResult.files.first;
    final bytes = file.bytes ?? await _readFileBytes(file);
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('file_pick_failed'.tr()),
        ),
      );
      return;
    }

    await _cubit.uploadParticipants(
      requestId: widget.requestId,
      fileBytes: bytes,
      filename: file.name,
      contentType: file.extension,
    );
  }

  Future<Uint8List?> _readFileBytes(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes;
    }
    final stream = file.readStream;
    if (stream == null) return null;
    final builder = BytesBuilder();
    await for (final chunk in stream) {
      builder.add(chunk);
    }
    return builder.toBytes();
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.request});

  final SchoolTripRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.schoolName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TripStatusChip(status: request.status),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                DateFormat.yMMMMd(context.locale.toString())
                    .format(request.preferredDate),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          if (request.preferredTime != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Text(
                  request.preferredTime!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                tr('trip_duration_hours', args: [request.durationHours.toString()]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.request});

  final SchoolTripRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalParticipants =
        request.studentsCount + request.accompanyingAdults;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'trip_basic_info'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.school_outlined,
              label: 'school_name'.tr(),
              value: request.schoolName,
            ),
            _InfoRow(
              icon: Icons.people_outline,
              label: 'students_count'.tr(),
              value: request.studentsCount.toString(),
            ),
            _InfoRow(
              icon: Icons.family_restroom_outlined,
              label: 'accompanying_adults'.tr(),
              value: request.accompanyingAdults.toString(),
            ),
            _InfoRow(
              icon: Icons.corporate_fare_outlined,
              label: 'total_participants'.tr(),
              value: totalParticipants.toString(),
            ),
            if (request.specialRequirements != null &&
                request.specialRequirements!.isNotEmpty)
              _InfoRow(
                icon: Icons.note_alt_outlined,
                label: 'special_requirements'.tr(),
                value: request.specialRequirements!,
              ),
            const Divider(height: 24),
            Text(
              'contact_information'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'contact_person'.tr(),
              value: request.contactPersonName,
            ),
            _InfoRow(
              icon: Icons.phone_enabled_outlined,
              label: 'contact_phone'.tr(),
              value: request.contactPhone,
            ),
            if (request.contactEmail != null)
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'contact_email'.tr(),
                value: request.contactEmail!,
              ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantsSection extends StatelessWidget {
  const _ParticipantsSection({required this.request});

  final SchoolTripRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final participants = request.participants;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Text(
          'participants_list'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          tr('participants_count', args: [participants.length.toString()]),
        ),
        children: [
          if (participants.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'no_participants_uploaded'.tr(),
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ...participants.map(
              (p) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(p.name),
                subtitle: Text(
                  tr(
                    'participant_details',
                    args: [
                      p.age.toString(),
                      p.guardianName,
                      p.guardianPhone,
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AddOnsSection extends StatelessWidget {
  const _AddOnsSection({required this.request});

  final SchoolTripRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addOns = request.addOns;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          'trip_addons'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          tr('addons_count', args: [addOns.length.toString()]),
        ),
        children: [
          if (addOns.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('no_addons_selected'.tr()),
            )
          else
            ...addOns.map(
              (addon) => ListTile(
                title: Text(addon.name),
                subtitle: Text(
                  tr(
                    'addon_details',
                    args: [
                      addon.quantity.toString(),
                      addon.price.toString(),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatusTimelineSection extends StatelessWidget {
  const _StatusTimelineSection({required this.request});

  final SchoolTripRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statuses = <TripRequestStatus>[
      TripRequestStatus.pending,
      TripRequestStatus.underReview,
      TripRequestStatus.approved,
      TripRequestStatus.invoiced,
      TripRequestStatus.paid,
      TripRequestStatus.completed,
    ];

    final currentIndex =
        statuses.indexWhere((status) => status == request.status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'trip_status_progress'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: statuses.map((status) {
                final index = statuses.indexOf(status);
                final reached = currentIndex >= index;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Icon(
                          reached ? Icons.check_circle : Icons.radio_button_off,
                          color:
                              reached ? theme.primaryColor : theme.disabledColor,
                        ),
                        if (index != statuses.length - 1)
                          Container(
                            width: 2,
                            height: 32,
                            color: reached
                                ? theme.primaryColor
                                : theme.disabledColor.withOpacity(0.4),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _statusLabel(status),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight:
                                reached ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
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

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({
    required this.request,
    required this.isSubmitting,
    required this.isUploading,
    required this.onSubmit,
    required this.onUpload,
  });

  final SchoolTripRequestEntity request;
  final bool isSubmitting;
  final bool isUploading;
  final VoidCallback onSubmit;
  final VoidCallback onUpload;

  bool get canSubmit =>
      request.status == TripRequestStatus.pending ||
      request.status == TripRequestStatus.underReview;

  bool get canUpload =>
      request.status == TripRequestStatus.pending ||
      request.status == TripRequestStatus.underReview;

  @override
  Widget build(BuildContext context) {
    if (!canSubmit && !canUpload) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canUpload)
          ElevatedButton.icon(
            onPressed: isUploading ? null : onUpload,
            icon: isUploading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file),
            label: Text('upload_participants'.tr()),
          ),
        const SizedBox(height: 12),
        if (canSubmit)
          ElevatedButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('submit_trip_request'.tr()),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

