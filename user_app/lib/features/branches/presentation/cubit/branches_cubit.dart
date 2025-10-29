import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/branches_repository.dart';
import 'branches_state.dart';

class BranchesCubit extends Cubit<BranchesState> {
  final BranchesRepository repository;

  BranchesCubit({required this.repository}) : super(BranchesState.initial());

  Future<void> loadAll({bool includeInactive = false}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final branches = await repository.getAllBranches(
        includeInactive: includeInactive,
      );
      emit(state.copyWith(loading: false, branches: branches, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
