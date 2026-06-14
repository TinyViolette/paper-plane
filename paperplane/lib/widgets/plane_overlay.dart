import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/plane/plane_cubit.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';

class PlaneOverlay extends StatefulWidget {
  const PlaneOverlay({super.key});

  @override
  State<PlaneOverlay> createState() => _PlaneOverlayState();
}

class _PlaneOverlayState extends State<PlaneOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _currentAnimation;

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
  }

  void _onStateChanged(BuildContext context, PlaneState state) {
    switch (state) {
      case PlaneMoving(:final currentOffset, :final targetOffset, :final duration):
        _animateTo(currentOffset, targetOffset, duration, Curves.linear);
      case PlaneReturning(:final currentOffset, :final targetOffset, :final duration):
        _animateReturning(currentOffset, targetOffset, duration);
      case PlaneFloating():
        _startFloating();
    }
  }

  void _animateTo(
    double from,
    double to,
    Duration duration,
    Curve curve,
  ) {
    _controller.stop();
    _currentAnimation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );
    _controller.duration = duration;
    _controller.forward(from: 0);
  }

  void _animateReturning(double from, double to, Duration duration) {
    _controller.stop();
    _currentAnimation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.duration = duration;
    _controller.forward(from: 0).then((_) {
      if (mounted) {
        context.read<PlaneCubit>().onAnimationComplete();
      }
    });
  }

  void _startFloating() {
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaneCubit, PlaneState>(
      listener: _onStateChanged,
      child: Center(
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
      ),
    );
  }
}
