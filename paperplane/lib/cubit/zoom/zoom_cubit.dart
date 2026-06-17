import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/zoom/zoom_state.dart';

class ZoomCubit extends Cubit<ZoomState> {
  ZoomCubit() : super(const ZoomUpdated(MapConstants.initialZoom));

  void zoomIn() {
    final newZoom = (state.zoom + MapConstants.zoomStep).clamp(
      MapConstants.minZoom,
      MapConstants.maxZoom,
    );
    emit(ZoomUpdated(newZoom));
  }

  void zoomBy(double delta) {
    final newZoom = (state.zoom + delta).clamp(
      MapConstants.minZoom,
      MapConstants.maxZoom,
    );
    emit(ZoomUpdated(newZoom));
  }

  void setZoom(double zoom) {
    final clamped = zoom.clamp(MapConstants.minZoom, MapConstants.maxZoom);
    emit(ZoomUpdated(clamped));
  }

  void zoomOut() {
    final newZoom = (state.zoom - MapConstants.zoomStep).clamp(
      MapConstants.minZoom,
      MapConstants.maxZoom,
    );
    emit(ZoomUpdated(newZoom));
  }
}
