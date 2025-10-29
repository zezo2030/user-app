import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/branch_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/url_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NearbyBranchesSection extends StatefulWidget {
  final List<BranchEntity> branches;
  final VoidCallback? onViewAll;

  const NearbyBranchesSection({
    Key? key,
    required this.branches,
    this.onViewAll,
  }) : super(key: key);

  @override
  State<NearbyBranchesSection> createState() => _NearbyBranchesSectionState();
}

class _NearbyBranchesSectionState extends State<NearbyBranchesSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.branches.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  _buildSectionHeader(),

                  const SizedBox(height: 20),

                  // Branches List
                  _buildBranchesList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title with Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.luxuryRedGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.luxuryDeepRed.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.near_me, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'nearby_branches'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.luxuryTextPrimary,
                    ),
                  ),
                  Text(
                    'closest_to_you'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.luxuryTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // View All Button
          if (widget.onViewAll != null)
            TextButton.icon(
              onPressed: widget.onViewAll,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text('view_all'.tr()),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBranchesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.branches.length,
      itemBuilder: (context, index) {
        final branch = widget.branches[index];
        // Mock distance data - in real app, this would be calculated based on user location
        final distance = 1.5 + (index * 0.8);

        return _buildNearbyBranchCard(branch, distance, index);
      },
    );
  }

  Widget _buildNearbyBranchCard(
    BranchEntity branch,
    double distance,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.luxuryShadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onBranchTap(branch),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Branch Image
                _buildBranchThumb(branch),

                const SizedBox(width: 16),

                // Branch Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Branch Name
                      Text(
                        context.locale.languageCode == 'ar'
                            ? branch.nameAr
                            : branch.nameEn,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.luxuryTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Location and Distance
                      Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 14,
                            color: AppColors.luxuryTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              branch.location,
                              style: TextStyle(
                                color: AppColors.luxuryTextSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.luxuryRedGradient.colors.first
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'distance_km'.tr(
                                args: [distance.toStringAsFixed(1)],
                              ),
                              style: TextStyle(
                                color: AppColors.luxuryDeepRed,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Status and Capacity
                      Row(
                        children: [
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: branch.status == 'active'
                                  ? AppColors.successColor.withOpacity(0.1)
                                  : AppColors.warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              branch.status == 'active'
                                  ? 'active'.tr()
                                  : 'inactive'.tr(),
                              style: TextStyle(
                                color: branch.status == 'active'
                                    ? AppColors.successColor
                                    : AppColors.warningColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Capacity
                          if (branch.capacity > 0)
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 12,
                                  color: AppColors.luxuryTextSecondary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'capacity'.tr(args: ['${branch.capacity}']),
                                  style: TextStyle(
                                    color: AppColors.luxuryTextSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Action Buttons
                Column(
                  children: [
                    // Directions Button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.luxuryRedGradient.colors.first
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.directions,
                        color: AppColors.luxuryDeepRed,
                        size: 20,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Book Button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.book_online,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchThumb(BranchEntity branch) {
    final img =
        branch.coverImage ??
        (branch.images?.isNotEmpty == true ? branch.images!.first : null);
    if (img == null || img.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.location_on,
            size: 30,
            color: Theme.of(context).primaryColor.withOpacity(0.7),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: resolveFileUrl(img),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorWidget: (c, url, e) => Container(
          width: 80,
          height: 80,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, size: 28, color: Colors.grey),
        ),
      ),
    );
  }

  void _onBranchTap(BranchEntity branch) {
    Navigator.of(
      context,
    ).pushNamed('/branch-details', arguments: {'branchId': branch.id});
  }
}
