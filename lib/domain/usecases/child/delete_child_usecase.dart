import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/core/usecases/usecase.dart';
import 'package:brighter_bites/domain/repositories/child_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteChildUseCase implements Usecase<void, DeleteChildParams>{
  final ChildRepository rep;
  DeleteChildUseCase(this.rep);

  @override
  Future<Either<Failure, void>> call(DeleteChildParams params) async {
    return await rep.deleteChild(params.childId);
  }
}

class DeleteChildParams {
  final String childId;
  DeleteChildParams({
    required this.childId,
  });
}