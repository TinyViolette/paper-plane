import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';

class PlaneOverlay extends StatelessWidget {
  const PlaneOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Cubit<PlaneState>, PlaneState>(
      buildWhen: (previous, current) =>
          previous.planeOffset != current.planeOffset ||
          previous.planeRotation != current.planeRotation ||
          previous.isFlipped != current.isFlipped,
      builder: (context, state) {
        return Center(
          child: Transform.translate(
            offset: state.planeOffset,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scaleByVector3(Vector3(state.isFlipped ? -1.0 : 1.0, 1.0, 1.0))
                ..rotateZ(state.planeRotation * pi / 180),
              child: Image.asset(
                'assets/images/plane.png',
                width: MapConstants.markerWidth,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}
