import 'package:latlong2/latlong.dart';

sealed class MarkerState {
  final List<LatLng> markers;

  const MarkerState(this.markers);
}

class MarkerUpdated extends MarkerState {
  const MarkerUpdated(super.markers);
}
