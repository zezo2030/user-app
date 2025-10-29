import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../branches/presentation/cubit/branches_cubit.dart';
import '../../../branches/presentation/cubit/branches_state.dart';
import '../../../branches/data/branches_api.dart';
import '../../../branches/data/branches_repository.dart';
import '../../../branches/presentation/widgets/branch_grid_card.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BranchesCubit(repository: BranchesRepositoryImpl(api: BranchesApi()))
            ..loadAll(),
      child: const _CategoryView(),
    );
  }
}

class _CategoryView extends StatelessWidget {
  const _CategoryView();

  void _openBranch(BuildContext context, String branchId) {
    Navigator.pushNamed(
      context,
      '/branch-details',
      arguments: {'branchId': branchId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BranchesCubit, BranchesState>(
      builder: (context, state) {
        if (state.loading && state.branches.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.branches.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.error!),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.read<BranchesCubit>().loadAll(),
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          );
        }
        if (state.branches.isEmpty) {
          return Center(child: Text('no_data'.tr()));
        }

        return RefreshIndicator(
          onRefresh: () => context.read<BranchesCubit>().loadAll(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemCount: state.branches.length,
            itemBuilder: (context, index) {
              final b = state.branches[index];
              return BranchGridCard(
                branch: b,
                onTap: () => _openBranch(context, b.id),
              );
            },
          ),
        );
      },
    );
  }
}
