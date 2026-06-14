sealed class ZoomState {
  final double zoom;

  const ZoomState(this.zoom);
}

class ZoomUpdated extends ZoomState {
  const ZoomUpdated(super.zoom);
}
