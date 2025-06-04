import 'dart:core';

import 'package:brighter_bites/core/error/failure.dart';
import 'package:brighter_bites/core/usecases/usecase.dart';
import 'package:brighter_bites/domain/entities/child.dart';
import 'package:brighter_bites/domain/repositories/child_repository.dart';
import 'package:dartz/dartz.dart';

class AddChildUseCase implements Usecase<Child, ChildParams> {
  final ChildRepository rep;
  const AddChildUseCase(this.rep);
  @override
  Future<Either<Failure, Child>> call(ChildParams params) async {
    return await rep.addChild(params.child);
  }
}

class ChildParams {
  final Child child;
  ChildParams({required this.child});
}
