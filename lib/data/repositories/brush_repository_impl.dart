import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/data/datasources/brush_remote_data_source.dart';
import 'package:brighter_bites/data/models/brush_model.dart';
import 'package:brighter_bites/domain/entities/brush.dart';
import 'package:brighter_bites/domain/repositories/brush_repository.dart';
import 'package:dartz/dartz.dart';

class BrushRepositoryImpl implements BrushRepository {
  final BrushRemoteDataSource remoteDataSource;

  BrushRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> addBrush(String childId, Brush brush) async {
    try {
      await remoteDataSource.addBrush(
          childId,
          BrushModel(
            id: brush.id,
            morning: brush.morning,
            night: brush.night,
          ));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeBrush(
      String childId, String brushId, bool time) async {
    try {
      await remoteDataSource.removeBrush(childId, brushId, time);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBrush(
      String childId, String brushId, bool time) async {
    try {
      await remoteDataSource.updateBrush(childId, brushId, time);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Brush>>> getBrushesForChild(
      String childId) async {
    try {
      final List<BrushModel> brushModels =
          await remoteDataSource.getBrushesForChild(childId);
      final List<Brush> brushes =
          brushModels.map((model) => model.toEntity()).toList();
      return Right(brushes);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
