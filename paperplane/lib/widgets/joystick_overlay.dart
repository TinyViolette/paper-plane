import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/joystick/joystick_cubit.dart';
import 'package:paperplane/cubit/joystick/joystick_state.dart';
import 'package:paperplane/cubit/plane/plane_cubit.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';

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
      child: BlocBuilder<PlaneCubit, PlaneState>(
        buildWhen: (prev, curr) =>
            prev.isLanded != curr.isLanded,
        builder: (context, planeState) {
          final enabled = !planeState.isLanded;
          return AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Opacity(
                opacity: enabled ? _fadeController.value : 0.05,
                child: child,
              );
            },
            child: IgnorePointer(
              ignoring: !enabled,
              child: GestureDetector(
                onPanStart: enabled ? _onPanStart : null,
                onPanUpdate: enabled ? _onPanUpdate : null,
                onPanEnd: enabled ? _onPanEnd : null,
                child: BlocBuilder<JoystickCubit, JoystickState>(
                  builder: (context, state) {
                    return CustomPaint(
                      size: Size(
                        MapConstants.joystickSize,
                        MapConstants.joystickSize,
                      ),
                      painter: _JoystickPainter(
                        offset: enabled ? state.offset : Offset.zero,
                        isEnabled: enabled,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final Offset offset;
  final bool isEnabled;

  _JoystickPainter({required this.offset, this.isEnabled = true});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Base circle
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.white.withValues(alpha: isEnabled ? 0.3 : 0.1),
    );

    // Knob
    final knobRadius = MapConstants.joystickKnobRadius;
    final maxKnobOffset = radius - knobRadius;
    final knobCenter = Offset(
      center.dx + offset.dx * maxKnobOffset,
      center.dy + offset.dy * maxKnobOffset,
    );
    canvas.drawCircle(
      knobCenter,
      knobRadius,
      Paint()
        ..color = isEnabled
            ? Colors.grey.shade400
            : Colors.grey.shade300.withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(_JoystickPainter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.isEnabled != isEnabled;
  }
}
