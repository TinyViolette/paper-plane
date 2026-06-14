import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/widgets/zoom_controls.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
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
          ZoomControls(mapController: _mapController),
        ],
      ),
    );
  }
}
