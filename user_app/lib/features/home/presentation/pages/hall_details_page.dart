import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dio/dio.dart';
import '../../di/home_injection.dart';
import '../../domain/usecases/get_hall_details_usecase.dart';
import '../../domain/entities/hall_entity.dart';
import '../cubit/hall_details_cubit.dart';
import '../cubit/hall_details_state.dart';
import '../widgets/hall_header_section.dart';
import '../widgets/hall_pricing_card.dart';
import '../widgets/hall_features_list.dart';
import '../widgets/hall_video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../home/presentation/widgets/offers_section.dart';
import '../../../booking/presentation/pages/hall_booking_wizard_page.dart';
import '../../../../core/realtime/socket_service.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../../core/routes/app_route_generator.dart';

class HallDetailsPage extends StatelessWidget {
  final String hallId;

  const HallDetailsPage({super.key, required this.hallId});

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

class HallDetailsView extends StatefulWidget {
  final String hallId;

  const HallDetailsView({super.key, required this.hallId});

  @override
  State<HallDetailsView> createState() => _HallDetailsViewState();
}

class _HallDetailsViewState extends State<HallDetailsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // best-effort leave; we don't know current hallId until loaded
    super.dispose();
  }

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
                      context.read<HallDetailsCubit>().loadHallDetails(
                        widget.hallId,
                      );
                    },
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          if (state is HallDetailsLoaded) {
            // Join realtime room and listen for updates
            SocketService.instance.joinHall(state.hall.id);
            SocketService.instance.onHallUpdated(state.hall.id).listen((
              payload,
            ) {
              final status = payload['status']?.toString();
              if (status != null && status.isNotEmpty) {
                // Trigger UI rebuild by reloading details (cheap approach)
                context.read<HallDetailsCubit>().loadHallDetails(state.hall.id);
              }
            });
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

              // Video Section
              if (hall.videoUrl != null && hall.videoUrl!.isNotEmpty)
                Column(
                  children: [
                    HallVideoPlayer(videoUrl: hall.videoUrl!),
                    const SizedBox(height: 16),
                  ],
                ),

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

              // Hall-specific Offers (fetched on-demand from /home?branchId=...)
              _HallOffersInline(branchId: hall.branchId, hallId: hall.id),

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

class _HallOffersInline extends StatefulWidget {
  final String branchId;
  final String hallId;

  const _HallOffersInline({required this.branchId, required this.hallId});

  @override
  State<_HallOffersInline> createState() => _HallOffersInlineState();
}

class _HallOffersInlineState extends State<_HallOffersInline> {
  List<dynamic> _offers = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = Dio();
      final res = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.homeEndpoint}',
        queryParameters: {'branchId': widget.branchId},
      );
      final data = res.data;
      final List<dynamic> allOffers = (data is Map && data['offers'] is List)
          ? (data['offers'] as List)
          : const [];
      // Filter offers that target this hallId
      final hallOffers = allOffers.where((o) {
        if (o is Map) {
          final dynamic hallId = o['hallId'];
          if (hallId == null) return false; // skip branch-wide offers here
          return hallId.toString() == widget.hallId;
        }
        return false;
      }).toList();
      setState(() {
        _offers = hallOffers;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox.shrink();
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const Icon(Iconsax.info_circle, color: Colors.red, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_error!, style: const TextStyle(fontSize: 12)),
            ),
            TextButton(onPressed: _fetchOffers, child: Text('retry'.tr())),
          ],
        ),
      );
    }
    if (_offers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'offers'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        OffersSection(offers: _offers),
        const SizedBox(height: 12),
      ],
    );
  }
}

class HallDetailsBottomBar extends StatelessWidget {
  final HallEntity hall;

  const HallDetailsBottomBar({super.key, required this.hall});

  Future<void> _proceedToBooking(BuildContext context) async {
    try {
      final dio = Dio();
      final res = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.hallsEndpoint}/${hall.id}',
      );
      String latestStatus = hall.status;
      if (res.data is Map) {
        final data = res.data as Map;
        final status = data['status'];
        if (status is String) {
          latestStatus = status;
        }
      }

      if (latestStatus.toLowerCase() != 'available') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('hall_not_available'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HallBookingWizardPage(
            hallId: hall.id,
            branchId: hall.branchId,
            hallName: hall.nameAr,
          ),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('hall_not_available'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
              child: Builder(
                builder: (context) {
                  final isBookable = hall.status.toLowerCase() == 'available';
                  final label = isBookable
                      ? 'book_hall'.tr()
                      : 'hall_not_available'.tr();

                  final theme = Theme.of(context);
                  final bool showGradient = isBookable;

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: showGradient
                          ? const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFFF5CAB),
                                Color(0xFFFF6A00),
                              ],
                            )
                          : null,
                      color: showGradient
                          ? null
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: isBookable
                          ? () {
                            // Check if user is authenticated
                            final authState = context.read<AuthCubit>().state;
                            if (authState is Guest) {
                              // Show login required message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('login_required'.tr()),
                                  backgroundColor: Colors.orange,
                                  action: SnackBarAction(
                                    label: 'login'.tr(),
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.pushNamed(context, AppRoutes.login);
                                    },
                                  ),
                                ),
                              );
                              return;
                            }

                            // Proceed with booking for authenticated users
                            _proceedToBooking(context);
                          }
                        : null,
                      icon: const Icon(Iconsax.calendar_1),
                      label: Text(label),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            theme.colorScheme.onSurfaceVariant,
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
