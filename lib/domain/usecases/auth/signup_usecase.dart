import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/core/usecases/usecase.dart';
import 'package:brighter_bites/domain/entities/user.dart';
import 'package:brighter_bites/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class SignupUseCase implements Usecase<User, SignUpParams> {
  final AuthRepository authRepository;
  const SignupUseCase(this.authRepository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await authRepository.signUpWithEmailPassord(
        name: params.name, email: params.email, password: params.password);
  }
}

class SignUpParams {
  final String name;
  final String email;
  final String password;
  const SignUpParams(
      {required this.name, required this.email, required this.password});
}
