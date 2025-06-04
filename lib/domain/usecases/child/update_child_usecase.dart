import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/domain/entities/child.dart';
import 'package:brighter_bites/domain/repositories/child_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateChildUseCase {
  final ChildRepository rep;
  UpdateChildUseCase(this.rep);

  Future<Either<Failure, void>> call(Child child) async {
    return await rep.updateChild(child);
  }
}
