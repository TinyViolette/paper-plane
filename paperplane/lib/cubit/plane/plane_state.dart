import 'dart:ui';

class PlaneState {
  final Offset planeOffset;
  final double floatAmplitude;
  final Duration floatHalfPeriod;
  final bool isJoystickEnabled;

  const PlaneState({
    required this.planeOffset,
    required this.floatAmplitude,
    required this.floatHalfPeriod,
    this.isJoystickEnabled = true,
  });
}
