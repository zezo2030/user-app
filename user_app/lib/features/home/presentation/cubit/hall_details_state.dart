import 'package:equatable/equatable.dart';
import '../../domain/entities/hall_entity.dart';

abstract class HallDetailsState extends Equatable {
  const HallDetailsState();

  @override
  List<Object?> get props => [];
}

class HallDetailsInitial extends HallDetailsState {}

class HallDetailsLoading extends HallDetailsState {}

class HallDetailsLoaded extends HallDetailsState {
  final HallEntity hall;

  const HallDetailsLoaded({required this.hall});

  @override
  List<Object?> get props => [hall];
}

class HallDetailsError extends HallDetailsState {
  final String message;

  const HallDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}
