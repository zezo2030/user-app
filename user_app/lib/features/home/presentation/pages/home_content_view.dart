import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/home_shimmer_loading.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/featured_offers_section.dart';
import '../widgets/popular_branches_section.dart';
import '../widgets/nearby_branches_section.dart';
import '../../../main/presentation/cubit/main_navigation_cubit.dart';
import 'all_offers_page.dart';
import '../../../branches/presentation/cubit/branches_cubit.dart';
import '../../../branches/presentation/cubit/branches_state.dart';

/// Home content view without scaffold
/// Used inside HomeTabsPage
class HomeContentView extends StatelessWidget {
  const HomeContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeInitial) {
          context.read<HomeCubit>().loadHomeData();
          return const HomeShimmerLoading();
        } else if (state is HomeLoading) {
          return const HomeShimmerLoading();
        } else if (state is HomeLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().refreshHomeData(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Home Header
                SliverToBoxAdapter(child: HomeHeaderWidget()),

                // Spacing after header
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Banner Carousel
                if (state.data.banners.isNotEmpty)
                  SliverToBoxAdapter(
                    child: BannerCarousel(banners: state.data.banners),
                  ),

                // Featured Offers Section
                if (state.data.offers.isNotEmpty)
                  SliverToBoxAdapter(
                    child: FeaturedOffersSection(
                      offers: state.data.offers,
                      onViewAll: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AllOffersPage(offers: state.data.offers),
                          ),
                        );
                      },
                    ),
                  ),

                // Popular Branches Section
                if (state.data.featuredBranches.isNotEmpty)
                  SliverToBoxAdapter(
                    child: PopularBranchesSection(
                      branches: state.data.featuredBranches.take(5).toList(),
                      onViewAll: () {
                        // Navigate to categories tab if available
                        try {
                          context.read<MainNavigationCubit>().changeTab(2);
                        } catch (e) {
                          // MainNavigationCubit not available in this context
                          print('MainNavigationCubit not available');
                        }
                      },
                    ),
                  ),

                // Nearby Branches Section
                SliverToBoxAdapter(
                  child: BlocBuilder<BranchesCubit, BranchesState>(
                    builder: (context, branchesState) {
                      final nearbySource = branchesState.branches.isNotEmpty
                          ? branchesState.branches
                          : state.data.featuredBranches;

                      if (nearbySource.isEmpty) return const SizedBox.shrink();

                      return NearbyBranchesSection(
                        branches: nearbySource,
                        onViewAll: () {
                          try {
                            context.read<MainNavigationCubit>().changeTab(2);
                          } catch (e) {
                            print('MainNavigationCubit not available');
                          }
                        },
                      );
                    },
                  ),
                ),

                // Empty state if no data
                if (state.data.banners.isEmpty &&
                    state.data.offers.isEmpty &&
                    state.data.featuredBranches.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'no_content_available'.tr(),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'check_back_later'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        } else if (state is HomeError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'error_loading_data'.tr(),
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<HomeCubit>().loadHomeData(),
                    icon: const Icon(Icons.refresh),
                    label: Text('retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
