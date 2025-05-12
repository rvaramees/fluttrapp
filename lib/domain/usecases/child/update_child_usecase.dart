import 'package:dartz/dartz.dart';
import 'package:fluttr_app/core/error/failure.dart';
import 'package:fluttr_app/domain/entities/child.dart';
import 'package:fluttr_app/domain/repositories/child_repository.dart';

class UpdateChildUseCase {
  final ChildRepository rep;
  UpdateChildUseCase(this.rep);

  Future<Either<Failure, void>> call(Child child) async {
    return await rep.updateChild(child);
  }
}
