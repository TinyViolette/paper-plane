import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/function_switcher/function_switcher_cubit.dart';
import 'package:paperplane/cubit/function_switcher/function_switcher_state.dart';
import 'package:paperplane/cubit/zoom/zoom_cubit.dart';
import 'package:paperplane/cubit/zoom/zoom_state.dart';

class ZoomScale extends StatelessWidget {
  static const double _pixelsPerUnit = 40.0;
  static const double _rulerHeight = 40.0;
  static const double _pointerSize = 10.0;

  const ZoomScale({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FunctionSwitcherCubit, FunctionSwitcherState>(
      builder: (context, funcState) {
        return BlocBuilder<ZoomCubit, ZoomState>(
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final visibleWidth = constraints.maxWidth;
                final rulerTotalWidth =
                    (MapConstants.maxZoom - MapConstants.minZoom) *
                        _pixelsPerUnit;
                final rulerOffset =
                    -(state.zoom - MapConstants.minZoom) * _pixelsPerUnit +
                        visibleWidth / 2;

                return SizedBox(
                  height: _rulerHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: rulerOffset,
                        top: 0,
                        width: rulerTotalWidth,
                        height: _rulerHeight,
                        child: CustomPaint(
                          painter: _RulerPainter(
                            state.zoom,
                            funcState.selectedIndex,
                          ),
                        ),
                      ),
                      Positioned(
                        left: visibleWidth / 2 - _pointerSize / 2,
                        top: 0,
                        child: CustomPaint(
                          size: Size(_pointerSize, _pointerSize),
                          painter: _PointerPainter(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double currentZoom;
  final int functionIndex;
  static const double _majorTickHeight = 14.0;
  static const double _minorTickHeight = 6.0;
  static const double _tickTop = 4.0;
  static const double _fadeStart = 2.0;
  static const double _fadeEnd = 4.0;

  _RulerPainter(this.currentZoom, this.functionIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final min = MapConstants.minZoom;
    final (double, double)? range;
    switch (functionIndex) {
      case 0:
        range = (MapConstants.blossomMinZoom, MapConstants.blossomMaxZoom);
      case 1:
        range = (MapConstants.bombMinZoom, MapConstants.bombMaxZoom);
      case 2:
        range = (MapConstants.maxZoom, MapConstants.maxZoom);
      default:
        range = null;
    }

    for (int i = 0; i <= ((MapConstants.maxZoom - min) * 10).round(); i++) {
      final value = min + i * 0.1;
      final distance = (value - currentZoom).abs();
      if (distance > _fadeEnd) continue;

      final opacity = distance <= _fadeStart
          ? 1.0
          : 1.0 - (distance - _fadeStart) / (_fadeEnd - _fadeStart);

      final isInRange =
          range != null && value >= range.$1 && value <= range.$2;
      final baseColor = isInRange ? Colors.orange : Colors.grey;

      final x = i * 0.1 * ZoomScale._pixelsPerUnit;
      final isMajor = (value - value.roundToDouble()).abs() < 0.001;
      final tickHeight = isMajor ? _majorTickHeight : _minorTickHeight;

      final tickPaint = Paint()
        ..color = baseColor.withValues(alpha: opacity)
        ..strokeWidth = 1.0;

      canvas.drawLine(
        Offset(x, _tickTop),
        Offset(x, _tickTop + tickHeight),
        tickPaint,
      );

      if (isMajor) {
        textPainter.text = TextSpan(
          text: value.round().toString(),
          style: TextStyle(
            color: baseColor.withValues(alpha: opacity),
            fontSize: 10,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, _tickTop + _majorTickHeight + 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) =>
      oldDelegate.currentZoom != currentZoom ||
      oldDelegate.functionIndex != functionIndex;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = Colors.red,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
