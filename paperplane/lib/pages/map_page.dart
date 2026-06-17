import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/joystick/joystick_cubit.dart';
import 'package:paperplane/cubit/joystick/joystick_state.dart';
import 'package:paperplane/cubit/plane/plane_cubit.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';
import 'package:paperplane/cubit/zoom/zoom_cubit.dart';
import 'package:paperplane/cubit/zoom/zoom_state.dart';
import 'package:paperplane/widgets/joystick_overlay.dart';
import 'package:paperplane/widgets/map_info_overlay.dart';
import 'package:paperplane/widgets/plane_overlay.dart';
import 'package:paperplane/widgets/random_teleport_button.dart';
import 'package:paperplane/widgets/zoom_controls.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  late final JoystickCubit _joystickCubit;
  late final ZoomCubit _zoomCubit;
  late final PlaneCubit _planeCubit;

  @override
  void initState() {
    super.initState();
    _joystickCubit = JoystickCubit();
    _zoomCubit = ZoomCubit();
    _planeCubit = PlaneCubit(_mapController, _joystickCubit);
  }

  @override
  void dispose() {
    _planeCubit.close();
    _joystickCubit.close();
    _zoomCubit.close();
    _mapController.dispose();
    super.dispose();
  }

  void _teleport() {
    final random = Random();
    final lat = MapConstants.randomTeleportMinLat +
        random.nextDouble() *
            (MapConstants.randomTeleportMaxLat - MapConstants.randomTeleportMinLat);
    final lng = MapConstants.randomTeleportMinLng +
        random.nextDouble() *
            (MapConstants.randomTeleportMaxLng - MapConstants.randomTeleportMinLng);
    final target = LatLng(lat, lng);
    _mapController.move(target, MapConstants.randomTeleportZoom);
    _zoomCubit.setZoom(MapConstants.randomTeleportZoom);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<JoystickCubit>.value(value: _joystickCubit),
        BlocProvider<ZoomCubit>.value(value: _zoomCubit),
        BlocProvider<Cubit<PlaneState>>.value(value: _planeCubit),
      ],
      child: BlocListener<ZoomCubit, ZoomState>(
        listener: (context, state) {
          _mapController.move(
            _mapController.camera.center,
            state.zoom,
          );
        },
        child: BlocListener<JoystickCubit, JoystickState>(
        listener: (context, state) {
          final zoom = _mapController.camera.zoom;
          final effectiveZoom = max(zoom, MapConstants.joystickSpeedMinEffectiveZoom);
          final speed = MapConstants.joystickMapSpeed *
              pow(2, MapConstants.initialZoom - effectiveZoom);
          final dx = state.offset.dx * speed;
          final dy = -state.offset.dy * speed;
          final center = _mapController.camera.center;
          _mapController.move(
            LatLng(center.latitude + dy, center.longitude + dx),
            _mapController.camera.zoom,
          );
        },
        child: Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: MapConstants.initialCenter,
                  initialZoom: MapConstants.initialZoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.paperplane',
                  ),
                ],
              ),
              MapInfoOverlay(_mapController),
              RandomTeleportButton(onPressed: _teleport),
              const PlaneOverlay(),
              const JoystickOverlay(),
              ZoomControls(
                onZoomButtonStart: () => _planeCubit.startZoomFloating(),
                onZoomButtonEnd: () => _planeCubit.stopZoomFloating(),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
