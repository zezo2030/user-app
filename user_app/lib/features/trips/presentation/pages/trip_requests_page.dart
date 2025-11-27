import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/widgets/custom_button.dart';
import '../../di/trips_injection.dart' as trips_di;
import '../../domain/entities/trip_request_status.dart';
import '../cubit/trip_requests_cubit.dart';
import '../cubit/trip_requests_state.dart';
import '../widgets/trip_request_card.dart';

class TripRequestsPage extends StatefulWidget {
  const TripRequestsPage({super.key});

  @override
  State<TripRequestsPage> createState() => _TripRequestsPageState();
}

class _TripRequestsPageState extends State<TripRequestsPage> {
  late final TripRequestsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = trips_di.sl<TripRequestsCubit>();
    _cubit.load();
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
          title: Text('school_trips_title'.tr()),
          centerTitle: true,
        ),
        body: BlocBuilder<TripRequestsCubit, TripRequestsState>(
          builder: (context, state) {
            if (state.isLoading && state.requests.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.hasError && state.requests.isEmpty) {
              return _buildErrorState(context, state.errorMessage ?? '');
            }

            return RefreshIndicator(
              onRefresh: () => _cubit.load(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _StatusFilterChips(
                    selectedStatus: state.statusFilter,
                    onChanged: (status) => _cubit.load(status: status),
                  ),
                  const SizedBox(height: 16),
                  if (state.requests.isEmpty) _buildEmptyState(theme),
                  ...state.requests.map(
                    (request) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TripRequestCard(
                        request: request,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/school-trips/details',
                            arguments: request,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.pushNamed(
              context,
              '/school-trips/create',
            );
            if (result != null) {
              _cubit.load(forceRefresh: true);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr('trip_request_created'))),
                );
              }
            }
          },
          icon: const Icon(Icons.add),
          label: Text('create_trip_request'.tr()),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 64, color: theme.primaryColor),
          const SizedBox(height: 16),
          Text(
            'no_trip_requests'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'start_first_trip_request'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'create_trip_request',
            onPressed: () =>
                Navigator.pushNamed(context, '/school-trips/create'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _cubit.load(forceRefresh: true),
            child: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChips extends StatelessWidget {
  const _StatusFilterChips({
    required this.selectedStatus,
    required this.onChanged,
  });

  final TripRequestStatus? selectedStatus;
  final ValueChanged<TripRequestStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final statuses = <TripRequestStatus?>[
      null,
      TripRequestStatus.pending,
      TripRequestStatus.underReview,
      TripRequestStatus.approved,
      TripRequestStatus.invoiced,
      TripRequestStatus.paid,
      TripRequestStatus.completed,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses
            .map(
              (status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: selectedStatus == status,
                  label: Text(_statusLabel(context, status)),
                  onSelected: (_) => onChanged(status),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  String _statusLabel(BuildContext context, TripRequestStatus? status) {
    if (status == null) {
      return tr('all');
    }
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
