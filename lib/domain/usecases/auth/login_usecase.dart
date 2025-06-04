import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/core/usecases/usecase.dart';
import 'package:brighter_bites/domain/entities/user.dart';
import 'package:brighter_bites/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LoginUseCase implements Usecase<User, LoginParams> {
  final AuthRepository authRepository;

  const LoginUseCase(this.authRepository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await authRepository.loginWithEmailPassword(
        email: params.email, password: params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
