import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/plane/plane_cubit.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';

class PlaneOverlay extends StatelessWidget {
  const PlaneOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaneCubit, PlaneState>(
      buildWhen: (previous, current) =>
          previous.planeOffset != current.planeOffset,
      builder: (context, state) {
        return Center(
          child: Transform.translate(
            offset: state.planeOffset,
            child: Image.asset(
              'assets/images/plane.png',
              width: MapConstants.markerWidth,
              fit: BoxFit.fitWidth,
            ),
          ),
        );
      },
    );
  }
}
