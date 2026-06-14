import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';

class PlaneCubit extends Cubit<PlaneState> {
  final MapController _mapController;
  StreamSubscription<MapEvent>? _mapSub;
  double _offset = 0;

  PlaneCubit(this._mapController) : super(const PlaneFloating(0)) {
    _mapSub = _mapController.mapEventStream.listen(_onMapEvent);
  }

  void _onMapEvent(MapEvent event) {
    final isAtMax =
        _mapController.camera.zoom >= MapConstants.maxZoom;

    if (isAtMax && state is PlaneFloating) {
      final distance = _offset.abs();
      if (distance < 0.001) return;

      emit(
        PlaneReturning(
          currentOffset: _offset,
          targetOffset: 0,
          duration: _durationForDistance(distance),
        ),
      );
    } else if (!isAtMax && state is PlaneReturning) {
      _startFloating();
    }
  }

  Duration _durationForDistance(double distance) {
    final seconds = distance / MapConstants.planeButtonMoveSpeed;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  void _startFloating() {
    emit(PlaneFloating(_offset));
  }

  void moveUp() {
    final distance = (_offset - (-MapConstants.planeFloatAmplitude)).abs();
    emit(
      PlaneMoving(
        currentOffset: _offset,
        targetOffset: -MapConstants.planeFloatAmplitude,
        duration: _durationForDistance(distance),
      ),
    );
  }

  void moveDown() {
    final distance = (_offset - MapConstants.planeFloatAmplitude).abs();
    emit(
      PlaneMoving(
        currentOffset: _offset,
        targetOffset: MapConstants.planeFloatAmplitude,
        duration: _durationForDistance(distance),
      ),
    );
  }

  void returnToCenter() {
    final distance = _offset.abs();
    if (distance < 0.001) {
      _startFloating();
      return;
    }

    emit(
      PlaneReturning(
        currentOffset: _offset,
        targetOffset: 0,
        duration: _durationForDistance(distance),
      ),
    );
  }

  void onAnimationComplete() {
    final currentState = state;
    _offset = switch (currentState) {
      PlaneMoving(:final targetOffset) => targetOffset,
      PlaneReturning(:final targetOffset) => targetOffset,
      PlaneFloating() => _offset,
    };

    _startFloating();
  }

  @override
  Future<void> close() {
    _mapSub?.cancel();
    return super.close();
  }
}
