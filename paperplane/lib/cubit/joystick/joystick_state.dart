import 'dart:ui';

sealed class JoystickState {
  final Offset offset; // normalized (-1..1, -1..1)

  const JoystickState(this.offset);
}

class JoystickIdle extends JoystickState {
  const JoystickIdle(super.offset);
}

class JoystickDragging extends JoystickState {
  const JoystickDragging(super.offset);
}

class JoystickAnimating extends JoystickState {
  const JoystickAnimating(super.offset);
}
