sealed class PlaneState {
  final double currentOffset;

  const PlaneState(this.currentOffset);
}

class PlaneFloating extends PlaneState {
  const PlaneFloating(super.currentOffset);
}

class PlaneMoving extends PlaneState {
  final double targetOffset;
  final Duration duration;

  const PlaneMoving({
    required double currentOffset,
    required this.targetOffset,
    required this.duration,
  }) : super(currentOffset);
}

class PlaneReturning extends PlaneState {
  final double targetOffset;
  final Duration duration;

  const PlaneReturning({
    required double currentOffset,
    required this.targetOffset,
    required this.duration,
  }) : super(currentOffset);
}
