import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/joystick/joystick_cubit.dart';
import 'package:paperplane/cubit/joystick/joystick_state.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';

class JoystickOverlay extends StatefulWidget {
  const JoystickOverlay({super.key});

  @override
  State<JoystickOverlay> createState() => _JoystickOverlayState();
}

class _JoystickOverlayState extends State<JoystickOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: MapConstants.joystickFadeDuration,
      value: MapConstants.joystickInactiveAlpha,
    );
    _animController = AnimationController(
      vsync: this,
      duration: MapConstants.joystickReturnDuration,
    );
    _animController.addListener(_onAnimFrame);
    _animController.addStatusListener(_onAnimStatus);
  }

  /// 每幀更新 cubit 位置。
  void _onAnimFrame() {
    final cubit = context.read<JoystickCubit>();
    final target = cubit.targetOffset;
    final t = _animController.value;
    final x = cubit.currentX + (target.dx - cubit.currentX) * t;
    final y = cubit.currentY + (target.dy - cubit.currentY) * t;
    cubit.animateToPosition(x, y);
  }

  /// 動畫完成，通知 cubit 回到 Idle。
  void _onAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      context.read<JoystickCubit>().emitIdle();
    }
  }

  /// 偵測 cubit 從非 Animating → Animating，啟動動畫。
  void _onJoystickStateChanged(BuildContext context, JoystickState state) {
    if (state is! JoystickAnimating) return;
    _animController.forward(from: 0);
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
    _animController.removeListener(_onAnimFrame);
    _animController.removeStatusListener(_onAnimStatus);
    _animController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 16,
      child: BlocConsumer<JoystickCubit, JoystickState>(
        listenWhen: (prev, curr) =>
            curr is JoystickAnimating && prev is! JoystickAnimating,
        listener: _onJoystickStateChanged,
        buildWhen: (prev, curr) =>
            prev.offset != curr.offset ||
            prev.runtimeType != curr.runtimeType,
        builder: (context, joystickState) {
          return BlocBuilder<Cubit<PlaneState>, PlaneState>(
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
                    child: CustomPaint(
                      size: Size(
                        MapConstants.joystickSize,
                        MapConstants.joystickSize,
                      ),
                      painter: _JoystickPainter(
                        offset: enabled ? joystickState.offset : Offset.zero,
                        isEnabled: enabled,
                      ),
                    ),
                  ),
                ),
              );
            },
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
