import 'dart:ui';

class PlaneState {
  final Offset planeOffset; // final clamped position
  final double floatAmplitude;
  final Duration floatHalfPeriod;

  const PlaneState({
    required this.planeOffset,
    required this.floatAmplitude,
    required this.floatHalfPeriod,
  });
}
