import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/constants/map_constants.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: MapConstants.initialCenter,
          initialZoom: MapConstants.initialZoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.paperplane',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: MapConstants.initialCenter,
                width: MapConstants.markerWidth,
                height: 200,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/plane.png',
                  width: MapConstants.markerWidth,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
