import 'package:equatable/equatable.dart';
import '../../domain/entities/hall_entity.dart';

abstract class HallsState extends Equatable {
  const HallsState();

  @override
  List<Object?> get props => [];
}

class HallsInitial extends HallsState {}

class HallsLoading extends HallsState {}

class HallsLoaded extends HallsState {
  final List<HallEntity> halls;

  const HallsLoaded({required this.halls});

  @override
  List<Object?> get props => [halls];
}

class HallsError extends HallsState {
  final String message;

  const HallsError({required this.message});

  @override
  List<Object?> get props => [message];
}
