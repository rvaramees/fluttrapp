part of 'selected_child_bloc.dart';

abstract class SelectedChildEvent extends Equatable {
  const SelectedChildEvent();

  @override
  List<Object> get props => [];
}

class SelectChild extends SelectedChildEvent {
  final Child child;

  const SelectChild({required this.child});

  @override
  List<Object> get props => [child];
}

class ClearSelectedChild extends SelectedChildEvent {
  const ClearSelectedChild();

  // @override
  // List<Object> get props => [];
} 

class CheckPreviousSelectedChild extends SelectedChildEvent {

  const CheckPreviousSelectedChild();

  // @override
  // List<Object> get props => [childId];
}