import 'package:dartz/dartz.dart';
import 'package:fluttr_app/core/error/failure.dart';
import 'package:fluttr_app/domain/entities/child.dart';
import 'package:fluttr_app/domain/repositories/child_repository.dart';

class GetChildrenUseCase {
  final ChildRepository rep;
  GetChildrenUseCase(this.rep);
  Future<Either<Failure, List<Child>>> call(String userId) async {
    return await rep.getChildrenForUser(userId);
  }
}
