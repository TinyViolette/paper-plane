import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/constants/map_constants.dart';

class PlaneOverlay extends StatefulWidget {
  final MapController mapController;

  const PlaneOverlay({super.key, required this.mapController});

  @override
  State<PlaneOverlay> createState() => PlaneOverlayState();
}

class PlaneOverlayState extends State<PlaneOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _currentAnimation;
  StreamSubscription<MapEvent>? _mapSub;
  bool _isReturning = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: MapConstants.planeFloatHalfPeriod,
    );

    _currentAnimation = Tween<double>(
      begin: -MapConstants.planeFloatAmplitude,
      end: MapConstants.planeFloatAmplitude,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startFloating();

    _mapSub = widget.mapController.mapEventStream.listen(_onMapEvent);
  }

  void _startFloating() {
    _isReturning = false;
    final current = _currentAnimation.value;

    _currentAnimation = Tween<double>(
      begin: current,
      end: current > 0
          ? -MapConstants.planeFloatAmplitude
          : MapConstants.planeFloatAmplitude,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.duration = MapConstants.planeFloatHalfPeriod;
    _controller.repeat(reverse: true);
  }

  void _onMapEvent(MapEvent event) {
    final isAtMax = widget.mapController.camera.zoom >= MapConstants.maxZoom;

    if (isAtMax && _controller.isAnimating && !_isReturning) {
      final current = _currentAnimation.value;
      _controller.stop();

      _currentAnimation = Tween<double>(
        begin: current,
        end: 0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _isReturning = true;
      _controller.duration = MapConstants.planeReturnDuration;
      _controller.forward(from: 0).then((_) {
        _isReturning = false;
      });
    } else if (!isAtMax && !_controller.isAnimating && !_isReturning) {
      _startFloating();
    }
  }

  Duration _durationForDistance(double distance) {
    final seconds = distance / MapConstants.planeButtonMoveSpeed;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  void moveUp() {
    _controller.stop();
    _isReturning = false;
    final current = _currentAnimation.value;
    final distance = (current - (-MapConstants.planeFloatAmplitude)).abs();

    _currentAnimation = Tween<double>(
      begin: current,
      end: -MapConstants.planeFloatAmplitude,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.duration = _durationForDistance(distance);
    _controller.forward(from: 0);
  }

  void moveDown() {
    _controller.stop();
    _isReturning = false;
    final current = _currentAnimation.value;
    final distance = (current - MapConstants.planeFloatAmplitude).abs();

    _currentAnimation = Tween<double>(
      begin: current,
      end: MapConstants.planeFloatAmplitude,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.duration = _durationForDistance(distance);
    _controller.forward(from: 0);
  }

  void returnToCenter() {
    _controller.stop();
    _isReturning = true;
    final current = _currentAnimation.value;
    final distance = current.abs();

    if (distance < 0.001) {
      _startFloating();
      return;
    }

    _currentAnimation = Tween<double>(
      begin: current,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.duration = _durationForDistance(distance);
    _controller.forward(from: 0).then((_) {
      _startFloating();
    });
  }

  @override
  void dispose() {
    _mapSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _currentAnimation.value),
            child: child,
          );
        },
        child: Image.asset(
          'assets/images/plane.png',
          width: MapConstants.markerWidth,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
