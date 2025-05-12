part of 'child_bloc.dart';

abstract class ChildEvent extends Equatable {
  const ChildEvent();

  @override
  List<Object> get props => [];
}

class LoadChildren extends ChildEvent {
  final String parentId;

  const LoadChildren({required this.parentId});

  @override
  List<Object> get props => [parentId];
}

class AddChild extends ChildEvent {
  final Child child;
  const AddChild({required this.child});

  @override
  List<Object> get props => [child];
}

class UpdateChild extends ChildEvent {
  final Child child;

  const UpdateChild({required this.child});

  @override
  List<Object> get props => [child];
}

class DeleteChild extends ChildEvent {
  final String childId;

  const DeleteChild({required this.childId});

  @override
  List<Object> get props => [childId];
}


class LoadChild extends ChildEvent {
  final String childId;

  const LoadChild({required this.childId});

  @override
  List<Object> get props => [childId];
}