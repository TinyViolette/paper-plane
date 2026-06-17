import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/blossom/blossom_cubit.dart';
import 'package:paperplane/cubit/blossom/blossom_state.dart';

class BlossomLayer extends StatelessWidget {
  final MapController mapController;

  const BlossomLayer({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlossomCubit, BlossomState>(
      builder: (context, state) {
        return StreamBuilder<MapEvent>(
          stream: mapController.mapEventStream,
          builder: (context, _) {
            final zoom = mapController.camera.zoom;
            final zoomScale =
                pow(2, zoom - MapConstants.blossomBaseZoom).toDouble();

            // 新的在最上面（反轉列表）
            final reversedBlossoms = state.blossoms.reversed.toList();

            return MarkerLayer(
              markers: reversedBlossoms.map((blossom) {
                final fontSize =
                    MapConstants.blossomBaseFontSize * zoomScale * blossom.scale;

                return Marker(
                  point: blossom.position,
                  width: fontSize,
                  height: fontSize,
                  child: ClipRect(
                    clipBehavior: Clip.none,
                    child: Transform.rotate(
                      angle: blossom.rotation * pi / 180,
                      child: Text(
                        '🌸',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
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
