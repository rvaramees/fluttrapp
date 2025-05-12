import 'dart:core';

import 'package:dartz/dartz.dart';
import 'package:fluttr_app/core/error/failure.dart';
import 'package:fluttr_app/core/usecases/usecase.dart';
import 'package:fluttr_app/domain/entities/child.dart';
import 'package:fluttr_app/domain/repositories/child_repository.dart';

class AddChildUseCase implements Usecase<Child, ChildParams> {
  final ChildRepository rep;
  const AddChildUseCase(this.rep);
  Future<Either<Failure, Child>> call(ChildParams params) async {
    return await rep.addChild(params.child);
  }
}

class ChildParams {
  final Child child;
  ChildParams({required this.child});
}
