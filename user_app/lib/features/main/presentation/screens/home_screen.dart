import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../../../home/presentation/cubit/home_state.dart';
import '../../../home/presentation/widgets/banner_carousel.dart';
import '../../../home/presentation/widgets/home_shimmer_loading.dart';
import '../../../home/presentation/widgets/home_header_widget.dart';
import '../../../home/presentation/widgets/featured_offers_section.dart';
import '../../../home/presentation/widgets/popular_branches_section.dart';
import '../../../home/presentation/widgets/nearby_branches_section.dart';
import '../cubit/main_navigation_cubit.dart';
import '../../../home/presentation/pages/all_offers_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeCubit, HomeState>(
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

                  // Quick Stats removed per request

                  // Banner Carousel
                  if (state.data.banners.isNotEmpty)
                    SliverToBoxAdapter(
                      child: BannerCarousel(banners: state.data.banners),
                    ),

                  // Featured Offers Section (Main Focus)
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
                          // الانتقال لتبويب الفروع/التصنيفات
                          context.read<MainNavigationCubit>().changeTab(2);
                        },
                      ),
                    ),

                  // Nearby Branches Section
                  if (state.data.featuredBranches.isNotEmpty)
                    SliverToBoxAdapter(
                      child: NearbyBranchesSection(
                        branches: state.data.featuredBranches.take(3).toList(),
                        onViewAll: () {
                          // الانتقال لتبويب الفروع/التصنيفات
                          context.read<MainNavigationCubit>().changeTab(2);
                        },
                      ),
                    ),

                  // Recommendations Section removed per request

                  // Featured branches section removed per request

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
      ),
    );
  }
}
