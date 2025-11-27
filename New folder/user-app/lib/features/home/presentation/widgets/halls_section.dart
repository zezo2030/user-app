import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import '../../di/home_injection.dart';
import '../../domain/usecases/get_halls_by_branch_usecase.dart';
import '../../domain/entities/hall_entity.dart';
import '../cubit/halls_cubit.dart';
import '../cubit/halls_state.dart';
import 'hall_card.dart';

class HallsSection extends StatelessWidget {
  final String branchId;

  const HallsSection({super.key, required this.branchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HallsCubit(getHallsByBranchUseCase: sl<GetHallsByBranchUseCase>())
            ..loadHallsByBranch(branchId),
      child: BlocBuilder<HallsCubit, HallsState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'halls'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state is HallsLoaded && state.halls.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all halls page
                        },
                        child: Text('view_all'.tr()),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Halls content
              _buildHallsContent(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHallsContent(BuildContext context, HallsState state) {
    if (state is HallsLoading) {
      return _buildLoadingState();
    }

    if (state is HallsError) {
      return _buildErrorState(context, state.message);
    }

    if (state is HallsLoaded) {
      if (state.halls.isEmpty) {
        return _buildEmptyState();
      }

      return _buildHallsList(context, state.halls);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: Colors.grey[200],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 120,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 80,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.info_circle, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<HallsCubit>().loadHallsByBranch(branchId);
                },
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.calendar_remove, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'no_halls_available'.tr(),
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHallsList(BuildContext context, List<HallEntity> halls) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: halls.length,
        itemBuilder: (context, index) {
          final hall = halls[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 0,
              right: index == halls.length - 1 ? 16 : 16,
            ),
            child: HallCard(
              hall: hall,
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed('/hall-details', arguments: {'hallId': hall.id});
              },
            ),
          );
        },
      ),
    );
  }
}
