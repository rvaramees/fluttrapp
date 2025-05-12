import 'package:dartz/dartz.dart';
import 'package:fluttr_app/core/error/failure.dart';
import 'package:fluttr_app/core/usecases/usecase.dart';
import 'package:fluttr_app/domain/entities/child.dart';
import 'package:fluttr_app/domain/repositories/child_repository.dart';

class GetChildUseCase implements Usecase<Child, GetChildParams> {
  final ChildRepository rep;
  GetChildUseCase(this.rep);
  Future<Either<Failure, Child>> call(GetChildParams params) async {
    return await rep.getChild(params.childId);
  }
}

class GetChildParams {
  final String childId;
  GetChildParams({
    required this.childId,
  });
}
