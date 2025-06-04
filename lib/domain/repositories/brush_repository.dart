import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/domain/entities/brush.dart';
import 'package:dartz/dartz.dart';

abstract class BrushRepository {
  Future<Either<Failure, void>> addBrush(String childId, Brush brush);
  Future<Either<Failure, void>> removeBrush(
      String childId, String brushId, bool time);
  Future<Either<Failure, void>> updateBrush(
      String childId, String brushId, bool time);
  Future<Either<Failure, List<Brush>>> getBrushesForChild(String childId);
}
