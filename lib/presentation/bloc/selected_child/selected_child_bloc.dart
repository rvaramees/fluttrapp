import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttr_app/domain/entities/child.dart';
import 'package:fluttr_app/domain/usecases/child/get_child_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'selected_child_event.dart';
part 'selected_child_state.dart';

class SelectedChildBloc extends Bloc<SelectedChildEvent, SelectedChildState> {
  final SharedPreferences sharedPreferences;
  final GetChildUseCase getChildUseCase;
  static const String selectedChildKey = 'selected_child';

  SelectedChildBloc(
      {required this.sharedPreferences, required this.getChildUseCase})
      : super(NoChildSelected()) {
    on<SelectChild>(_onSelectChild);
    on<ClearSelectedChild>(_onClearSelectedChild);
    on<CheckPreviousSelectedChild>(_onCheckPreviousSelectedChild);
  }

  Future<void> _onSelectChild(
      SelectChild event, Emitter<SelectedChildState> emit) async {
    emit(ChildSelected(child: event.child, childName: event.child.name));
    await sharedPreferences.setString(
        selectedChildKey, event.child.childId); // Persist the selected child ID
  }

  Future<void> _onClearSelectedChild(
      ClearSelectedChild event, Emitter<SelectedChildState> emit) async {
    emit(NoChildSelected());
    await sharedPreferences
        .remove(selectedChildKey); // Clear the persisted child ID
  }

  Future<void> _onCheckPreviousSelectedChild(CheckPreviousSelectedChild event,
      Emitter<SelectedChildState> emit) async {
    final String? selectedChildId =
        sharedPreferences.getString(selectedChildKey);

    if (selectedChildId != null) {
      final result = await getChildUseCase(GetChildParams(childId: selectedChildId));
      result.fold(
        (failure) => emit(NoChildSelected()),
        (child) {
          final childName = child.name; // Access the child's name!
          print('Previous Child Name: $childName'); // Example logging
          emit(ChildSelected(
              child: child, childName: childName)); // Send the child to the UI!
          //OR emit(ChildSelectedWithName(child: child, childName: childName)); //Send name to custom state.
        },
      );
    } else {
      emit(NoChildSelected());
    }
  }
}
