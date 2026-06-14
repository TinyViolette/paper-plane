import 'package:latlong2/latlong.dart';

class MapConstants {
  static const double initialZoom = 19;
  static const LatLng initialCenter = LatLng(25.095073530311385, 121.24963231240274);
  static const double markerWidth = 50;

  static const double minZoom = 0;
  static const double maxZoom = 19;
  static const double zoomStep = 0.01;
  static const Duration zoomRepeatDuration = Duration(milliseconds: 200);

  static const double planeFloatAmplitude = 3;
  static const Duration planeFloatHalfPeriod = Duration(seconds: 1);
  static const Duration planeReturnDuration = Duration(seconds: 3);
  static const double planeButtonMoveSpeed = 2.0; // px/s
}
