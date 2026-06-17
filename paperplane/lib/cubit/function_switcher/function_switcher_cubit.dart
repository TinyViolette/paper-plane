import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/cubit/function_switcher/function_switcher_state.dart';

class FunctionSwitcherCubit extends Cubit<FunctionSwitcherState> {
  static const int totalFunctions = 3;

  FunctionSwitcherCubit() : super(const FunctionSwitcherUpdated(0));

  void next() {
    final newIndex = (state.selectedIndex + 1) % totalFunctions;
    emit(FunctionSwitcherUpdated(newIndex));
  }

  void previous() {
    final newIndex =
        (state.selectedIndex - 1 + totalFunctions) % totalFunctions;
    emit(FunctionSwitcherUpdated(newIndex));
  }
}
