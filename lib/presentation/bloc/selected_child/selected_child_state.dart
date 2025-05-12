part of 'selected_child_bloc.dart';

sealed class SelectedChildState extends Equatable {
  const SelectedChildState();
  
  @override
  List<Object> get props => [];
}

final class NoChildSelected extends SelectedChildState {

  // const NoChildSelected();

  // @override
  // List<Object> get props => [];
}

final class ChildSelected extends SelectedChildState {
  final Child child;
  final String childName;

  const ChildSelected({required this.child, required this.childName});

  @override
  List<Object> get props => [child];
}
