sealed class FunctionSwitcherState {
  final int selectedIndex;

  const FunctionSwitcherState(this.selectedIndex);
}

class FunctionSwitcherUpdated extends FunctionSwitcherState {
  const FunctionSwitcherUpdated(super.selectedIndex);
}
