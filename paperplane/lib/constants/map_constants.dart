import 'package:latlong2/latlong.dart';

class MapConstants {
  static const double initialZoom = 6;
  static const LatLng initialCenter = LatLng(0, 0);
  static const double markerWidth = 50;

  static const double minZoom = 0;
  static const double maxZoom = 19;
  static const double zoomStep = 0.01;
  static const Duration zoomRepeatDuration = Duration(milliseconds: 200);
}
