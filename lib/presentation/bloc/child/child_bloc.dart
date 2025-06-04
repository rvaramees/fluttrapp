
import 'package:brighter_bites/domain/entities/child.dart';
import 'package:brighter_bites/domain/usecases/child/add_child_usecase.dart';
import 'package:brighter_bites/domain/usecases/child/delete_child_usecase.dart';
import 'package:brighter_bites/domain/usecases/child/get_children_usecase.dart';
import 'package:brighter_bites/domain/usecases/child/update_child_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'child_event.dart';
part 'child_state.dart';

class ChildBloc extends Bloc<ChildEvent, ChildState> {
  final GetChildrenUseCase getChildren;
  final AddChildUseCase addChild;
  final UpdateChildUseCase updateChild;
  final DeleteChildUseCase deleteChild;

  ChildBloc({
    required this.getChildren,
    required this.addChild,
    required this.updateChild,
    required this.deleteChild,
  }) : super(ChildInitial()) {
    on<LoadChildren>(_onLoadChildren);
    on<AddChild>(_onAddChild);
    on<UpdateChild>(_onUpdateChild);
    on<DeleteChild>(_onDeleteChild);
  }

  Future<void> _onLoadChildren(
      LoadChildren event, Emitter<ChildState> emit) async {
    emit(ChildLoading());
    final result = await getChildren(event.parentId);
    result.fold(
      (failure) => emit(ChildError(message: failure.message)),
      (children) => emit(ChildLoaded(children: children)),
    );
  }

  Future<void> _onAddChild(AddChild event, Emitter<ChildState> emit) async {
    emit(ChildLoading());
    final result = await addChild(ChildParams(child: event.child));
    result.fold((failure) => emit(ChildError(message: failure.message)),
        (newChild) {
      if (state is ChildLoaded) {
        final updatedChildren =
            List<Child>.from((state as ChildLoaded).children)..add(newChild);
        emit(ChildLoaded(children: updatedChildren));
      } else {
        emit(ChildLoaded(children: [newChild]));
      }
    });
  }

  Future<void> _onUpdateChild(
      UpdateChild event, Emitter<ChildState> emit) async {
    emit(ChildLoading());
    final result = await updateChild(event.child);
    result.fold((failure) => emit(ChildError(message: failure.message)), (_) {
      if (state is ChildLoaded) {
        final updatedChildren = (state as ChildLoaded).children.map((child) {
          if (child.childId == event.child.childId) {
            return event.child;
          }
          return child;
        }).toList();
        emit(ChildLoaded(children: updatedChildren));
      }
    });
  }

  Future<void> _onDeleteChild(
      DeleteChild event, Emitter<ChildState> emit) async {
    emit(ChildLoading());
    final result = await deleteChild(DeleteChildParams(childId: event.childId));
    result.fold((failure) => emit(ChildError(message: failure.message)), (_) {
      if (state is ChildLoaded) {
        final updatedChildren = (state as ChildLoaded)
            .children
            .where((child) => child.childId != event.childId)
            .toList();
        emit(ChildLoaded(children: updatedChildren));
      }
    });
  }
}
