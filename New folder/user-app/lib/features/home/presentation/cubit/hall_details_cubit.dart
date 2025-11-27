import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_hall_details_usecase.dart';
import 'hall_details_state.dart';

class HallDetailsCubit extends Cubit<HallDetailsState> {
  final GetHallDetailsUseCase getHallDetailsUseCase;

  HallDetailsCubit({required this.getHallDetailsUseCase}) : super(HallDetailsInitial());

  Future<void> loadHallDetails(String hallId) async {
    if (isClosed) return;
    emit(HallDetailsLoading());
    
    final result = await getHallDetailsUseCase(hallId);
    
    if (isClosed) return;
    result.fold(
      (failure) => emit(HallDetailsError(message: failure.message)),
      (hall) => emit(HallDetailsLoaded(hall: hall)),
    );
  }

  Future<void> refreshHallDetails(String hallId) async {
    if (isClosed) return;
    await loadHallDetails(hallId);
  }
}
