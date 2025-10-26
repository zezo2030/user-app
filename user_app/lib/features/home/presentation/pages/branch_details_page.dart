import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../di/home_injection.dart';
import '../../domain/usecases/get_branch_details_usecase.dart';
import '../../domain/entities/branch_entity.dart';
import '../cubit/branch_details_cubit.dart';
import '../cubit/branch_details_state.dart';
import '../widgets/hero_banner_widget.dart';
import '../widgets/seasonal_offers_section.dart';
import '../widgets/featured_branches_section.dart';
import '../widgets/welcome_section.dart';

class BranchDetailsPage extends StatelessWidget {
  final String branchId;

  const BranchDetailsPage({
    Key? key,
    required this.branchId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BranchDetailsCubit(
        getBranchDetailsUseCase: sl<GetBranchDetailsUseCase>(),
      )..loadBranchDetails(branchId),
      child: BranchDetailsView(branchId: branchId),
    );
  }
}

class BranchDetailsView extends StatelessWidget {
  final String branchId;
  
  const BranchDetailsView({Key? key, required this.branchId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<BranchDetailsCubit, BranchDetailsState>(
        builder: (context, state) {
          if (state is BranchDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryRed,
              ),
            );
          }

          if (state is BranchDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 64,
                    color: AppColors.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.errorColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BranchDetailsCubit>().loadBranchDetails(branchId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          if (state is BranchDetailsLoaded) {
            return Stack(
              children: [
                _buildBranchDetails(context, state.branch),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BranchDetailsBottomBar(branch: state.branch),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBranchDetails(BuildContext context, BranchEntity branch) {
    return CustomScrollView(
      slivers: [
        // Custom App Bar
        SliverAppBar(
          expandedHeight: 0,
          floating: true,
          pinned: true,
          backgroundColor: AppColors.primaryRed,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_right_3, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.notification, color: Colors.white),
              onPressed: () {
                // TODO: Handle notification tap
              },
            ),
          ],
        ),
        
        // Hero Banner
        SliverToBoxAdapter(
          child: HeroBannerWidget(
            title: 'want_to_change_mood'.tr(),
            subtitle: 'with_tornado_entertainment'.tr(),
            onTap: () {
              // TODO: Handle banner tap
            },
          ),
        ),
        
        // Content
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Seasonal Offers Section
              MockSeasonalOffersSection(
                onViewMore: () {
                  // TODO: Navigate to offers page
                },
                onOfferTap: (offerTitle) {
                  // TODO: Handle offer tap
                  print('Offer tapped: $offerTitle');
                },
              ),
              
              const SizedBox(height: 24),
              
              // Featured Branches Section
              MockFeaturedBranchesSection(
                onViewMore: () {
                  // TODO: Navigate to branches page
                },
                onBranchTap: (branchName) {
                  // TODO: Handle branch tap
                  print('Branch tapped: $branchName');
                },
              ),
              
              const SizedBox(height: 24),
              
              // Welcome Section
              MockWelcomeSection(
                onViewMore: () {
                  // TODO: Navigate to all branches page
                },
                onBranchTap: (branchName) {
                  // TODO: Handle branch tap
                  print('Welcome branch tapped: $branchName');
                },
              ),
              
              const SizedBox(height: 100), // Space for bottom action bar
            ]),
          ),
        ),
      ],
    );
  }
}

class BranchDetailsBottomBar extends StatelessWidget {
  final BranchEntity branch;

  const BranchDetailsBottomBar({
    Key? key,
    required this.branch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
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
                  // TODO: View on map
                },
                icon: const Icon(Iconsax.location),
                label: Text('branches'.tr()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryRed,
                  side: const BorderSide(color: AppColors.primaryRed),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: View map
                },
                icon: const Icon(Iconsax.map),
                label: Text('map'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
