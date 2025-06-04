import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/core/usecases/usecase.dart';
import 'package:brighter_bites/domain/entities/brush.dart';
import 'package:brighter_bites/domain/repositories/brush_repository.dart';
import 'package:dartz/dartz.dart';

class AddBrushUseCase implements Usecase<void, BrushParams> {
  final BrushRepository repository;

  const AddBrushUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(BrushParams params) async {
    return await repository.addBrush(params.brush.id, params.brush);
  }
}

class BrushParams {
  final Brush brush;
  BrushParams({required this.brush});
}
