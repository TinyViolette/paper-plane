import 'package:flutter/animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/joystick/joystick_state.dart';

class JoystickCubit extends Cubit<JoystickState> {
  AnimationController? _controller;
  double _x = 0;
  double _y = 0;
  double _animStartX = 0;
  double _animStartY = 0;
  double _animTargetX = 0;
  double _animTargetY = 0;
  bool _isAnimating = false;

  JoystickCubit() : super(const JoystickIdle(Offset.zero));

  void attachTicker(TickerProvider ticker) {
    _controller = AnimationController(
      vsync: ticker,
      duration: MapConstants.joystickReturnDuration,
    );
    _controller!.addListener(_onAnimFrame);
    _controller!.addStatusListener(_onAnimStatus);
  }

  void _onAnimFrame() {
    if (!_isAnimating) return;
    final t = _controller!.value;
    _x = _animStartX + (_animTargetX - _animStartX) * t;
    _y = _animStartY + (_animTargetY - _animStartY) * t;
    emit(JoystickAnimating(Offset(_x, _y)));
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _isAnimating = false;
      _x = _animTargetX;
      _y = _animTargetY;
      emit(JoystickIdle(Offset(_x, _y)));
    }
  }

  void updateDrag(Offset normalizedOffset) {
    _controller?.stop();
    _isAnimating = false;
    _x = normalizedOffset.dx.clamp(-1.0, 1.0);
    _y = normalizedOffset.dy.clamp(-1.0, 1.0);
    emit(JoystickDragging(Offset(_x, _y)));
  }

  void endDrag() {
    _animateTo(0, 0, MapConstants.joystickReturnDuration);
  }

  void moveUp() {
    final distance = (_y - (-1.0)).abs();
    final seconds = distance / MapConstants.planeButtonMoveSpeed;
    _animateTo(
      _x,
      -1.0,
      Duration(milliseconds: (seconds * 1000).round()),
    );
  }

  void moveDown() {
    final distance = (_y - 1.0).abs();
    final seconds = distance / MapConstants.planeButtonMoveSpeed;
    _animateTo(
      _x,
      1.0,
      Duration(milliseconds: (seconds * 1000).round()),
    );
  }

  void returnToCenter() {
    _animateTo(0, 0, MapConstants.joystickReturnDuration);
  }

  void _animateTo(double targetX, double targetY, Duration duration) {
    _animStartX = _x;
    _animStartY = _y;
    _animTargetX = targetX;
    _animTargetY = targetY;
    _isAnimating = true;
    _controller!.duration = duration;
    _controller!.forward(from: 0);
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
