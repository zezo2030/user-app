import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_halls_by_branch_usecase.dart';
import 'halls_state.dart';

class HallsCubit extends Cubit<HallsState> {
  final GetHallsByBranchUseCase getHallsByBranchUseCase;

  HallsCubit({required this.getHallsByBranchUseCase}) : super(HallsInitial());

  Future<void> loadHallsByBranch(String branchId) async {
    if (isClosed) return;
    emit(HallsLoading());
    
    final result = await getHallsByBranchUseCase(branchId);
    
    if (isClosed) return;
    result.fold(
      (failure) => emit(HallsError(message: failure.message)),
      (halls) => emit(HallsLoaded(halls: halls)),
    );
  }

  Future<void> refreshHalls(String branchId) async {
    if (isClosed) return;
    await loadHallsByBranch(branchId);
  }
}
