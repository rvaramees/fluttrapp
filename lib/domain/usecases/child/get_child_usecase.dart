import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/core/usecases/usecase.dart';
import 'package:brighter_bites/domain/entities/child.dart';
import 'package:brighter_bites/domain/repositories/child_repository.dart';
import 'package:dartz/dartz.dart';

class GetChildUseCase implements Usecase<Child, GetChildParams> {
  final ChildRepository rep;
  GetChildUseCase(this.rep);
  @override
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
