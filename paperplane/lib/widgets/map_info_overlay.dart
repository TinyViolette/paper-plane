import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapInfoOverlay extends StatelessWidget {
  final MapController mapController;

  const MapInfoOverlay(this.mapController, {super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 16,
      child: Center(
        child: StreamBuilder<MapEvent>(
          stream: mapController.mapEventStream,
          builder: (context, _) {
            final camera = mapController.camera;
            final center = camera.center;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                '${center.latitude.toStringAsFixed(5)}, '
                '${center.longitude.toStringAsFixed(5)}, '
                '(zoom: ${camera.zoom.toStringAsFixed(2)})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
