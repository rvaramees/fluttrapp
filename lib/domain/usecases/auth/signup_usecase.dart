import 'package:dartz/dartz.dart';
import 'package:fluttr_app/core/error/failure.dart';
import 'package:fluttr_app/core/usecases/usecase.dart';
import 'package:fluttr_app/domain/entities/user.dart';
import 'package:fluttr_app/domain/repositories/auth_repository.dart';

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
