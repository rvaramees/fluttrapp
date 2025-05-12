import 'package:dartz/dartz.dart';
import 'package:fluttr_app/core/error/failure.dart';
import 'package:fluttr_app/core/usecases/usecase.dart';
import 'package:fluttr_app/domain/repositories/child_repository.dart';

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