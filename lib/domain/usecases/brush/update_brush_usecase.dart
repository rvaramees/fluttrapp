import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/core/usecases/usecase.dart';
import 'package:brighter_bites/domain/repositories/brush_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateBrushUseCase implements Usecase<void, UpdateBrushParams> {

  final BrushRepository repository;
  const UpdateBrushUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(UpdateBrushParams params) {
     return repository.updateBrush(params.childId, params.brushId, params.time);
  }
}

class UpdateBrushParams {
  final String childId;
  final String brushId;
  final bool time;

  UpdateBrushParams({
    required this.childId,
    required this.brushId,
    required this.time,
  });
  
}
