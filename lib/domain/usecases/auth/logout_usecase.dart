import 'package:dartz/dartz.dart';
import 'package:fluttr_app/core/error/failure.dart';
import 'package:fluttr_app/core/usecases/usecase.dart';
import 'package:fluttr_app/domain/repositories/auth_repository.dart';

class LogoutUseCase implements Usecase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.signOut();
  }
}
