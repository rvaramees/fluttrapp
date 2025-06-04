import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/domain/entities/child.dart';
import 'package:dartz/dartz.dart';

abstract class ChildRepository {
  Future<Either<Failure, Child>> addChild(Child child);
  Future<Either<Failure, void>> updateChild(Child child);
  Future<Either<Failure, void>> deleteChild(String childId);
  Future<Either<Failure, List<Child>>> getChildrenForUser(String userId);
  Future<Either<Failure, Child>> getChild(String childId);
}
