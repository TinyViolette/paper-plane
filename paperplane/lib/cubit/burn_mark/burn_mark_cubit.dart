import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:paperplane/cubit/burn_mark/burn_mark_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BurnMarkCubit extends Cubit<BurnMarkState> {
  static const String _storageKey = 'burn_marks';

  BurnMarkCubit() : super(const BurnMarkUpdated([])) {
    _loadBurnMarks();
  }

  Future<void> _loadBurnMarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final burnMarks = jsonList
          .map((item) => LatLng(item['lat'] as double, item['lng'] as double))
          .toList();
      emit(BurnMarkUpdated(burnMarks));
    }
  }

  Future<void> _saveBurnMarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.burnMarks
        .map((mark) => {'lat': mark.latitude, 'lng': mark.longitude})
        .toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  void addBurnMark(LatLng position) {
    final updatedMarks = List<LatLng>.from(state.burnMarks)..add(position);
    emit(BurnMarkUpdated(updatedMarks));
    _saveBurnMarks();
  }
}
