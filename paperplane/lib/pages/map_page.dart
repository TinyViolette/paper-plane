import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/burn_mark/burn_mark_cubit.dart';
import 'package:paperplane/cubit/function_switcher/function_switcher_cubit.dart';
import 'package:paperplane/cubit/joystick/joystick_cubit.dart';
import 'package:paperplane/cubit/joystick/joystick_state.dart';
import 'package:paperplane/cubit/marker/marker_cubit.dart';
import 'package:paperplane/cubit/plane/plane_cubit.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';
import 'package:paperplane/cubit/zoom/zoom_cubit.dart';
import 'package:paperplane/cubit/zoom/zoom_state.dart';
import 'package:paperplane/widgets/bomb_overlay.dart';
import 'package:paperplane/widgets/burn_mark_layer.dart';
import 'package:paperplane/widgets/function_switcher.dart';
import 'package:paperplane/widgets/joystick_overlay.dart';
import 'package:paperplane/widgets/map_info_overlay.dart';
import 'package:paperplane/widgets/map_markers.dart';
import 'package:paperplane/widgets/plane_overlay.dart';
import 'package:paperplane/widgets/zoom_controls.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final GlobalKey<BombOverlayState> _bombOverlayKey = GlobalKey<BombOverlayState>();
  late final JoystickCubit _joystickCubit;
  late final ZoomCubit _zoomCubit;
  late final PlaneCubit _planeCubit;
  late final MarkerCubit _markerCubit;
  late final BurnMarkCubit _burnMarkCubit;
  late final FunctionSwitcherCubit _functionSwitcherCubit;

  @override
  void initState() {
    super.initState();
    _joystickCubit = JoystickCubit();
    _zoomCubit = ZoomCubit();
    _planeCubit = PlaneCubit(_mapController, _joystickCubit);
    _markerCubit = MarkerCubit();
    _burnMarkCubit = BurnMarkCubit();
    _functionSwitcherCubit = FunctionSwitcherCubit();
  }

  @override
  void dispose() {
    _functionSwitcherCubit.close();
    _burnMarkCubit.close();
    _markerCubit.close();
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

  void _addMarker() {
    final center = _mapController.camera.center;
    _markerCubit.addMarker(center);
  }

  LatLng _offsetToLatLng(Offset pixelOffset, LatLng reference, double zoom) {
    // 每個像素代表的米數（Web Mercator 投影）
    final metersPerPixel =
        156543.03392 * cos(reference.latitude * pi / 180) / pow(2, zoom);

    // 像素偏移轉換為米
    final dxMeters = pixelOffset.dx * metersPerPixel;
    final dyMeters = pixelOffset.dy * metersPerPixel;

    // 米轉換為經緯度
    final lat = reference.latitude - (dyMeters / 111320);
    final lng = reference.longitude +
        (dxMeters / (111320 * cos(reference.latitude * pi / 180)));

    return LatLng(lat, lng);
  }

  void _bomb() {
    final center = _mapController.camera.center;
    final planeOffset = _planeCubit.state.planeOffset;
    final zoom = _mapController.camera.zoom;

    final planeLatLng = _offsetToLatLng(planeOffset, center, zoom);
    final dropLatLng = _offsetToLatLng(
      Offset(0, MapConstants.bombDropOffset),
      planeLatLng,
      zoom,
    );

    _bombOverlayKey.currentState?.triggerBomb(planeOffset, dropLatLng);
  }

  void _handleFunctionTap() {
    final selectedIndex = _functionSwitcherCubit.state.selectedIndex;
    if (selectedIndex == 0) {
      _bomb();
    } else if (selectedIndex == 1) {
      _addMarker();
    } else {
      _teleport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<JoystickCubit>.value(value: _joystickCubit),
        BlocProvider<ZoomCubit>.value(value: _zoomCubit),
        BlocProvider<Cubit<PlaneState>>.value(value: _planeCubit),
        BlocProvider<MarkerCubit>.value(value: _markerCubit),
        BlocProvider<BurnMarkCubit>.value(value: _burnMarkCubit),
        BlocProvider<FunctionSwitcherCubit>.value(value: _functionSwitcherCubit),
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
                  const MapMarkers(),
                  BurnMarkLayer(mapController: _mapController),
                ],
              ),
              MapInfoOverlay(_mapController),
              FunctionSwitcher(
                mapController: _mapController,
                onSwipeLeft: () => _functionSwitcherCubit.next(),
                onSwipeRight: () => _functionSwitcherCubit.previous(),
                onTap: _handleFunctionTap,
              ),
              BombOverlay(mapController: _mapController, key: _bombOverlayKey),
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
