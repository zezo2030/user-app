import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hall_entity.dart';
import '../repositories/home_repository.dart';

class GetHallsByBranchUseCase {
  final HomeRepository repository;

  GetHallsByBranchUseCase({required this.repository});

  Future<Either<Failure, List<HallEntity>>> call(String branchId) async {
    return await repository.getHallsByBranch(branchId);
  }
}
