import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/cubit/marker/marker_cubit.dart';
import 'package:paperplane/cubit/marker/marker_state.dart';

class MapMarkers extends StatelessWidget {
  const MapMarkers({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarkerCubit, MarkerState>(
      builder: (context, state) {
        return MarkerLayer(
          markers: state.markers.map((position) {
            return Marker(
              point: position,
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  // Do nothing
                },
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
