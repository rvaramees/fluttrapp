import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/core/usecases/usecase.dart';
import 'package:brighter_bites/domain/entities/brush.dart';
import 'package:brighter_bites/domain/repositories/brush_repository.dart';
import 'package:dartz/dartz.dart';

class GetBrushesUseCase implements Usecase<List<Brush>, GetBrushParams>{
  final BrushRepository repository;

  const GetBrushesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Brush>>> call(GetBrushParams params) async {
    final result = await repository.getBrushesForChild(params.childId);
    return result.fold(
      (failure) => Left(failure),
      (brushes) => Right(brushes),
    );
  }
}

class GetBrushParams {
  final String childId;

  GetBrushParams({required this.childId});
}