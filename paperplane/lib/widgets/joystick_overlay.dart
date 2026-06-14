import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/joystick/joystick_cubit.dart';
import 'package:paperplane/cubit/joystick/joystick_state.dart';

class JoystickOverlay extends StatefulWidget {
  const JoystickOverlay({super.key});

  @override
  State<JoystickOverlay> createState() => _JoystickOverlayState();
}

class _JoystickOverlayState extends State<JoystickOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: MapConstants.joystickFadeDuration,
      value: MapConstants.joystickInactiveAlpha,
    );
    context.read<JoystickCubit>().attachTicker(this);
  }

  void _onPanStart(DragStartDetails details) {
    _fadeController.animateTo(MapConstants.joystickActiveAlpha);
    _updateJoystick(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _updateJoystick(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    _fadeController.animateTo(MapConstants.joystickInactiveAlpha);
    context.read<JoystickCubit>().endDrag();
  }

  void _updateJoystick(Offset localPosition) {
    final center = Offset(
      MapConstants.joystickSize / 2,
      MapConstants.joystickSize / 2,
    );
    final delta = localPosition - center;
    final radius = MapConstants.joystickSize / 2;
    final normalized = Offset(
      (delta.dx / radius).clamp(-1.0, 1.0),
      (delta.dy / radius).clamp(-1.0, 1.0),
    );
    context.read<JoystickCubit>().updateDrag(normalized);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 16,
      child: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(opacity: _fadeController.value, child: child);
        },
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: BlocBuilder<JoystickCubit, JoystickState>(
            builder: (context, state) {
              return CustomPaint(
                size: Size(MapConstants.joystickSize, MapConstants.joystickSize),
                painter: _JoystickPainter(offset: state.offset),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final Offset offset;

  _JoystickPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // White transparent base circle
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );

    // Gray knob
    final knobRadius = MapConstants.joystickKnobRadius;
    final maxKnobOffset = radius - knobRadius;
    final knobCenter = Offset(
      center.dx + offset.dx * maxKnobOffset,
      center.dy + offset.dy * maxKnobOffset,
    );
    canvas.drawCircle(
      knobCenter,
      knobRadius,
      Paint()..color = Colors.grey.shade400,
    );
  }

  @override
  bool shouldRepaint(_JoystickPainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}
