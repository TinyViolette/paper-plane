import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/plane/plane_cubit.dart';
import 'package:paperplane/cubit/zoom/zoom_cubit.dart';
import 'package:paperplane/cubit/zoom/zoom_state.dart';
import 'package:paperplane/widgets/plane_overlay.dart';
import 'package:paperplane/widgets/zoom_controls.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  late final PlaneCubit _planeCubit;
  late final ZoomCubit _zoomCubit;

  @override
  void initState() {
    super.initState();
    _planeCubit = PlaneCubit(_mapController);
    _zoomCubit = ZoomCubit();
  }

  @override
  void dispose() {
    _planeCubit.close();
    _zoomCubit.close();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlaneCubit>.value(value: _planeCubit),
        BlocProvider<ZoomCubit>.value(value: _zoomCubit),
      ],
      child: BlocListener<ZoomCubit, ZoomState>(
        listener: (context, state) {
          _mapController.move(_mapController.camera.center, state.zoom);
        },
        child: Scaffold(
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
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.paperplane',
                  ),
                ],
              ),
              const PlaneOverlay(),
              const ZoomControls(),
            ],
          ),
        ),
      ),
    );
  }
}
