import 'package:dartz/dartz.dart';
import 'package:fluttr_app/core/error/failure.dart';
import 'package:fluttr_app/data/datasources/auth_remote_data_source.dart';
import 'package:fluttr_app/domain/entities/user.dart';
import 'package:fluttr_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> loginWithEmailPassword(
      {required String email, required String password}) async {
    try {
      final userModel = await remoteDataSource.loginWithEmailPassword(
          email: email, password: password);
      return Right(userModel.toEntity()); // Convert UserModel to User Entity
    } catch (e) {
      return Left(AuthFailure(
          message: e.toString())); // Translate backend error to Failure
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassord(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmailPassword(
          email: email, password: password, name: name);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel
          ?.toEntity()); // Convert UserModel to User Entity, may return null
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
