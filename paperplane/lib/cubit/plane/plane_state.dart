import 'dart:ui';

class PlaneState {
  final Offset planeOffset;
  final double floatAmplitude;
  final Duration floatHalfPeriod;
  final bool isLanded;
  final double planeRotation;
  final bool isFlipped;

  const PlaneState({
    required this.planeOffset,
    required this.floatAmplitude,
    required this.floatHalfPeriod,
    this.isLanded = true,
    this.planeRotation = 0,
    this.isFlipped = false,
  });
}
