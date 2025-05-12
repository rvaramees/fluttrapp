import 'package:dartz/dartz.dart';
import 'package:fluttr_app/core/error/failure.dart';

abstract interface class Usecase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
