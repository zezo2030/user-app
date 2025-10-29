import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../tickets/data/datasources/tickets_remote_datasource.dart';
import '../../../core/network/dio_client.dart';
import '../../activities/data/bookings_api.dart';
import '../../activities/data/bookings_repository.dart';
import '../../activities/domain/booking_status.dart';
import 'activities_cubit.dart';
import '../../booking/presentation/pages/booking_details_page.dart';
import 'widgets/booking_card.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActivitiesCubit(
        repository: BookingsRepositoryImpl(api: BookingsApi()),
        ticketsDs: TicketsRemoteDataSourceImpl(dio: DioClient.instance),
      ),
      child: const _ActivitiesView(),
    );
  }
}

class _ActivitiesView extends StatefulWidget {
  const _ActivitiesView();

  @override
  State<_ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<_ActivitiesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ActivitiesCubit>().loadTab(BookingStatusFilter.all);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesCubit, ActivitiesState>(
      builder: (context, state) {
        if (state.loading && state.bookings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.error!),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.read<ActivitiesCubit>().loadTab(
                    BookingStatusFilter.all,
                  ),
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          );
        }

        if (state.bookings.isEmpty) {
          return Center(child: Text('no_bookings_found'.tr()));
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ActivitiesCubit>().refresh(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 200 &&
                  state.canLoadMore &&
                  !state.loading) {
                context.read<ActivitiesCubit>().loadMore();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: state.bookings.length + (state.canLoadMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.bookings.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final booking = state.bookings[index];
                return BookingCard(
                  booking: booking,
                  ticketsDs: context.read<ActivitiesCubit>().ticketsDs,
                  onDetails: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (_, animation, __) => FadeTransition(
                          opacity: animation,
                          child: BookingDetailsPage(booking: booking),
                        ),
                        transitionsBuilder: (_, animation, __, child) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
