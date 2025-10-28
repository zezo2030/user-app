import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import '../../di/home_injection.dart';
import '../../domain/usecases/get_hall_details_usecase.dart';
import '../../domain/entities/hall_entity.dart';
import '../cubit/hall_details_cubit.dart';
import '../cubit/hall_details_state.dart';
import '../widgets/hall_header_section.dart';
import '../widgets/hall_pricing_card.dart';
import '../widgets/hall_features_list.dart';
import '../widgets/working_hours_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../booking/presentation/pages/hall_booking_page.dart';
import '../../../booking/di/booking_injection.dart' as booking;
import '../../../booking/presentation/cubit/booking_cubit.dart';

class HallDetailsPage extends StatelessWidget {
  final String hallId;

  const HallDetailsPage({Key? key, required this.hallId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HallDetailsCubit(getHallDetailsUseCase: sl<GetHallDetailsUseCase>())
            ..loadHallDetails(hallId),
      child: HallDetailsView(hallId: hallId),
    );
  }
}

class HallDetailsView extends StatelessWidget {
  final String hallId;

  const HallDetailsView({Key? key, required this.hallId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HallDetailsCubit, HallDetailsState>(
        builder: (context, state) {
          if (state is HallDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HallDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.info_circle, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HallDetailsCubit>().loadHallDetails(hallId);
                    },
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          if (state is HallDetailsLoaded) {
            return Stack(
              children: [
                _buildHallDetails(context, state.hall),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: HallDetailsBottomBar(hall: state.hall),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHallDetails(BuildContext context, HallEntity hall) {
    return CustomScrollView(
      slivers: [
        // Header section
        SliverToBoxAdapter(child: HallHeaderSection(hall: hall)),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              // Description
              if (hall.descriptionAr != null || hall.descriptionEn != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.document_text,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'description'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.locale.languageCode == 'ar'
                              ? hall.descriptionAr ?? hall.descriptionEn ?? ''
                              : hall.descriptionEn ?? hall.descriptionAr ?? '',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Hall info cards
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Iconsax.people, color: Colors.green, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'hall_capacity'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${hall.capacity}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Iconsax.tick_circle,
                              color: _getStatusColor(hall.status),
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'hall_status'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStatusText(hall.status),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(hall.status),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Pricing information
              HallPricingCard(hall: hall),

              const SizedBox(height: 16),

              // Features
              if (hall.features != null && hall.features!.isNotEmpty)
                HallFeaturesList(features: hall.features!),

              const SizedBox(height: 100), // Space for bottom action bar
            ]),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.availableColor;
      case 'maintenance':
        return AppColors.maintenanceColor;
      case 'reserved':
        return AppColors.reservedColor;
      default:
        return AppColors.greyMedium;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'available'.tr();
      case 'maintenance':
        return 'maintenance'.tr();
      case 'reserved':
        return 'reserved'.tr();
      default:
        return status;
    }
  }
}

class HallDetailsBottomBar extends StatelessWidget {
  final HallEntity hall;

  const HallDetailsBottomBar({Key? key, required this.hall}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Share hall
                },
                icon: const Icon(Iconsax.send_2),
                label: Text('share'.tr()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => booking.sl<BookingCubit>(),
                        child: HallBookingPage(
                          hallId: hall.id,
                          branchId: hall.branchId,
                          hallName: hall.nameAr,
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Iconsax.calendar_1),
                label: Text('book_hall'.tr()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
