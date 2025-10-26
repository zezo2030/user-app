import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../di/home_injection.dart';
import '../../domain/usecases/get_branch_details_usecase.dart';
import '../../domain/entities/branch_entity.dart';
import '../cubit/branch_details_cubit.dart';
import '../cubit/branch_details_state.dart';
import '../widgets/branch_header_section.dart';
import '../widgets/branch_info_card.dart';
import '../widgets/working_hours_widget.dart';
import '../widgets/amenities_grid.dart';

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
      body: BlocBuilder<BranchDetailsCubit, BranchDetailsState>(
        builder: (context, state) {
          if (state is BranchDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is BranchDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BranchDetailsCubit>().loadBranchDetails(branchId);
                    },
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

  Widget _buildBranchDetails(BuildContext context, branch) {
    return CustomScrollView(
      slivers: [
        // Header section
        SliverToBoxAdapter(
          child: BranchHeaderSection(branch: branch),
        ),
        
        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              
              // Description
              if (branch.descriptionAr != null || branch.descriptionEn != null)
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
                              Icons.description,
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
                              ? branch.descriptionAr ?? branch.descriptionEn ?? ''
                              : branch.descriptionEn ?? branch.descriptionAr ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Branch info cards
              Row(
                children: [
                  Expanded(
                    child: BranchInfoCard(
                      icon: Icons.people,
                      title: 'capacity_info'.tr(),
                      value: branch.capacity > 0 
                          ? 'capacity'.tr(args: ['${branch.capacity}'])
                          : 'capacity_not_available'.tr(),
                      iconColor: branch.capacity > 0 ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BranchInfoCard(
                      icon: Icons.phone,
                      title: 'phone'.tr(),
                      value: branch.contactPhone ?? 'not_available'.tr(),
                      onTap: branch.contactPhone != null 
                          ? () => _makePhoneCall(branch.contactPhone!)
                          : null,
                      iconColor: branch.contactPhone != null ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Working hours
              WorkingHoursWidget(branch: branch),
              
              const SizedBox(height: 16),
              
              // Amenities
              AmenitiesGrid(branch: branch),
              
              const SizedBox(height: 100), // Space for bottom action bar
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // TODO: Implement phone call functionality
    // This would require adding url_launcher package to pubspec.yaml
    print('Calling: $phoneNumber');
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
                  // TODO: View on map
                },
                icon: const Icon(Icons.map),
                label: Text('view_on_map'.tr()),
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
                  // TODO: Book branch
                },
                icon: const Icon(Icons.book_online),
                label: Text('book_branch'.tr()),
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
