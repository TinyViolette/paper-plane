import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/joystick/joystick_cubit.dart';
import 'package:paperplane/cubit/joystick/joystick_state.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';

enum FloatMode { none, joystick, zoom }

class PlaneCubit extends Cubit<PlaneState> {
  final MapController _mapController;
  final JoystickCubit _joystickCubit;
  StreamSubscription<MapEvent>? _mapSub;
  StreamSubscription<JoystickState>? _joystickSub;
  Timer? _floatTimer;
  double _floatPhase = 0;
  FloatMode _floatMode = FloatMode.joystick;

  PlaneCubit(this._mapController, this._joystickCubit)
      : super(
          PlaneState(
            planeOffset: Offset.zero,
            floatAmplitude: MapConstants.joystickFloatAmplitude,
            floatHalfPeriod: const Duration(seconds: 1),
          ),
        ) {
    _mapSub = _mapController.mapEventStream.listen(_onMapEvent);
    _joystickSub = _joystickCubit.stream.listen(_onJoystickChanged);
    _startFloating();
  }

  void _onMapEvent(MapEvent event) {
    final isAtMax = _mapController.camera.zoom >= MapConstants.maxZoom;
    if (isAtMax && _floatMode != FloatMode.none) {
      _floatMode = FloatMode.none;
      _floatTimer?.cancel();
      _joystickCubit.returnToCenter();
      _emitState();
    } else if (!isAtMax && _floatMode == FloatMode.none) {
      _floatMode = FloatMode.joystick;
      _startFloating();
    }
  }

  void _onJoystickChanged(JoystickState joystickState) {
    final isAtMax = _mapController.camera.zoom >= MapConstants.maxZoom;
    if (isAtMax) return;

    if (joystickState is JoystickAnimating && _floatMode != FloatMode.zoom) {
      _floatMode = FloatMode.zoom;
      _floatPhase = 0;
    } else if (joystickState is! JoystickAnimating &&
        _floatMode == FloatMode.zoom) {
      _floatMode = FloatMode.joystick;
    }
    _emitState();
  }

  void startZoomFloating() {
    _floatMode = FloatMode.zoom;
    _floatPhase = 0;
  }

  void stopZoomFloating() {
    if (_floatMode == FloatMode.zoom) {
      _floatMode = FloatMode.joystick;
    }
  }

  void _startFloating() {
    _floatTimer?.cancel();
    _floatTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _tick();
    });
  }

  void _tick() {
    if (_floatMode == FloatMode.none) return;

    final halfPeriod = _currentHalfPeriod;
    final periodSeconds = halfPeriod.inMilliseconds / 1000 * 2;
    _floatPhase += (2 * pi) / (periodSeconds * 60);
    if (_floatPhase > 2 * pi) _floatPhase -= 2 * pi;

    _emitState();
  }

  double get _currentAmplitude {
    switch (_floatMode) {
      case FloatMode.none:
        return 0;
      case FloatMode.zoom:
        return MapConstants.zoomFloatAmplitude;
      case FloatMode.joystick:
        return MapConstants.joystickFloatAmplitude;
    }
  }

  Duration get _currentHalfPeriod {
    switch (_floatMode) {
      case FloatMode.none:
        return Duration.zero;
      case FloatMode.zoom:
        return MapConstants.zoomFloatHalfPeriod;
      case FloatMode.joystick:
        return _joystickHalfPeriod;
    }
  }

  Duration get _joystickHalfPeriod {
    final distance = _joystickCubit.state.offset.distance.clamp(0.0, 1.0);
    final ms = lerpDouble(
      MapConstants.floatSpeedMinHalfPeriod * 1000,
      MapConstants.floatSpeedMaxHalfPeriod * 1000,
      distance,
    )!;
    return Duration(milliseconds: ms.round());
  }

  void _emitState() {
    final joystick = _joystickCubit.state.offset;
    final floatY = sin(_floatPhase) * _currentAmplitude;

    final joystickOffset = Offset(
      joystick.dx * MapConstants.joystickFloatAmplitude,
      joystick.dy * MapConstants.joystickFloatAmplitude,
    );
    final totalOffset = joystickOffset + Offset(0, floatY);
    final clamped = _clampToRadius(totalOffset, MapConstants.planeMoveRadiusLimit);

    emit(PlaneState(
      planeOffset: clamped,
      floatAmplitude: _currentAmplitude,
      floatHalfPeriod: _currentHalfPeriod,
    ));
  }

  Offset _clampToRadius(Offset offset, double radius) {
    if (offset.distance <= radius) return offset;
    return offset * (radius / offset.distance);
  }

  @override
  Future<void> close() {
    _floatTimer?.cancel();
    _mapSub?.cancel();
    _joystickSub?.cancel();
    return super.close();
  }
}
