import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/core/usecases/usecase.dart';
import 'package:brighter_bites/domain/repositories/brush_repository.dart';
import 'package:dartz/dartz.dart';

class RemoveBrushUseCase implements Usecase<void, RemoveBrushParams> {
  final BrushRepository repository;
  const RemoveBrushUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(RemoveBrushParams params) {
    return repository.removeBrush(params.childId, params.brushId, params.time);
  }
}

class RemoveBrushParams {
  final String childId;
  final String brushId;
  final bool time;

  RemoveBrushParams({
    required this.childId,
    required this.brushId,
    required this.time,
  });
}
