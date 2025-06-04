import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/core/usecases/usecase.dart';
import 'package:brighter_bites/domain/entities/user.dart';
import 'package:brighter_bites/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetCurrentUserUseCase implements Usecase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
