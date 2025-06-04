import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/domain/entities/child.dart';
import 'package:brighter_bites/domain/repositories/child_repository.dart';
import 'package:dartz/dartz.dart';

class GetChildrenUseCase {
  final ChildRepository rep;
  GetChildrenUseCase(this.rep);
  Future<Either<Failure, List<Child>>> call(String userId) async {
    return await rep.getChildrenForUser(userId);
  }
}
