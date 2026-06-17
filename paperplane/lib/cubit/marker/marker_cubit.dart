import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:paperplane/cubit/marker/marker_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarkerCubit extends Cubit<MarkerState> {
  static const String _storageKey = 'map_markers';

  MarkerCubit() : super(const MarkerUpdated([])) {
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final markers = jsonList
          .map((item) => LatLng(item['lat'] as double, item['lng'] as double))
          .toList();
      emit(MarkerUpdated(markers));
    }
  }

  Future<void> _saveMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.markers
        .map((marker) => {'lat': marker.latitude, 'lng': marker.longitude})
        .toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  void addMarker(LatLng position) {
    final updatedMarkers = List<LatLng>.from(state.markers)..add(position);
    emit(MarkerUpdated(updatedMarkers));
    _saveMarkers();
  }
}
