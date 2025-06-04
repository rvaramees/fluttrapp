import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassord(
      {required String name, required String email, required String password});
  Future<Either<Failure, User>> loginWithEmailPassword(
      {required String email, required String password});
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User?>> getCurrentUser();
}
