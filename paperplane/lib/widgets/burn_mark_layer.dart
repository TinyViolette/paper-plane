import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/burn_mark/burn_mark_cubit.dart';
import 'package:paperplane/cubit/burn_mark/burn_mark_state.dart';

class BurnMarkLayer extends StatelessWidget {
  final MapController mapController;

  const BurnMarkLayer({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BurnMarkCubit, BurnMarkState>(
      builder: (context, state) {
        return StreamBuilder<MapEvent>(
          stream: mapController.mapEventStream,
          builder: (context, _) {
            final zoom = mapController.camera.zoom;
            final scale = pow(2, zoom - MapConstants.burnMarkBaseZoom);
            final size = MapConstants.burnMarkRadius * 2 * scale;

            return MarkerLayer(
              markers: state.burnMarks.map((position) {
                return Marker(
                  point: position,
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: _BurnMarkPainter(),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}

class _BurnMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: MapConstants.burnMarkOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
