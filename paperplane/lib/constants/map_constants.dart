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

  static const double joystickSize = 120;
  static const double joystickKnobRadius = 20;
  static const double joystickInactiveAlpha = 0.3;
  static const double joystickActiveAlpha = 1.0;
  static const Duration joystickFadeDuration = Duration(milliseconds: 200);
  static const Duration joystickReturnDuration = Duration(milliseconds: 500);
  static const double joystickMapSpeed = 0.00001; // deg/s at full deflection

  static const double planeMoveRadiusLimit = 5.0; // px

  static const double joystickFloatAmplitude = 3.0;
  static const double zoomFloatAmplitude = 1.0;
  static const Duration zoomFloatHalfPeriod = Duration(milliseconds: 500);
  static const double floatSpeedMinHalfPeriod = 1.0; // seconds (joystick center)
  static const double floatSpeedMaxHalfPeriod = 0.5; // seconds (joystick edge)
}
