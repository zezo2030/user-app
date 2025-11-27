import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hall_entity.dart';
import '../repositories/home_repository.dart';

class GetHallDetailsUseCase {
  final HomeRepository repository;

  GetHallDetailsUseCase({required this.repository});

  Future<Either<Failure, HallEntity>> call(String hallId) async {
    return await repository.getHallDetails(hallId);
  }
}
