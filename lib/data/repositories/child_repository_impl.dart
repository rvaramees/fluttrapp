import 'package:dartz/dartz.dart';
import 'package:fluttr_app/core/error/failure.dart';
import 'package:fluttr_app/data/datasources/child_remote_data_source.dart';
import 'package:fluttr_app/data/models/child_model.dart';
import 'package:fluttr_app/domain/entities/child.dart';
import 'package:fluttr_app/domain/repositories/child_repository.dart';

class ChildRepositoryImpl implements ChildRepository {
  final ChildRemoteDataSource remoteDataSource;

  ChildRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Child>>> getChildrenForUser(String userId) async {
    try {
      final List<ChildModel> childModels =
          await remoteDataSource.getChildrenForUser(userId);
      final List<Child> children =
          childModels.map((model) => model.toEntity()).toList();
      return Right(children);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Child>> addChild(Child child) async {
    try {
      final ChildModel childModel = ChildModel(
          childId: child.childId,
          name: child.name,
          age: child.age,
          level: child.level,
          exp: child.exp,
          preferences: child.preferences,
          parentId: child.parentId,
          password: child.password);
      final ChildModel newChildModel =
          await remoteDataSource.addChild(childModel);
      return Right(newChildModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateChild(Child child) async {
    try {
      final ChildModel childModel = ChildModel(
          childId: child.childId,
          name: child.name,
          age: child.age,
          level: child.level,
          exp: child.exp,
          preferences: child.preferences,
          parentId: child.parentId,
          password: child.password);
      await remoteDataSource.updateChild(childModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChild(
      String childId) async {
    try {
      await remoteDataSource.deleteChild(childId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Child>> getChild(String childId) async {
    try {
      final ChildModel childModel =
          await remoteDataSource.getChild(childId);
      return Right(childModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
