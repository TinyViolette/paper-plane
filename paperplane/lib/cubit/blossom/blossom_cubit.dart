import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/blossom/blossom_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlossomCubit extends Cubit<BlossomState> {
  static const String _storageKey = 'blossoms';

  BlossomCubit() : super(const BlossomUpdated([])) {
    _loadBlossoms();
  }

  Future<void> _loadBlossoms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final blossoms = jsonList
          .map((item) => BlossomData.fromJson(item as Map<String, dynamic>))
          .toList();

      // 移除超過保鮮期的花
      final now = DateTime.now();
      final validBlossoms = blossoms
          .where((b) =>
              now.difference(b.timestamp) < MapConstants.blossomFreshnessPeriod)
          .toList();

      emit(BlossomUpdated(validBlossoms));
      _saveBlossoms();
    }
  }

  Future<void> _saveBlossoms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.blossoms.map((b) => b.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  void addBlossom(BlossomData blossom) {
    final updatedBlossoms = List<BlossomData>.from(state.blossoms)
      ..add(blossom);

    // 超過最大數量時刪除最舊的
    if (updatedBlossoms.length > MapConstants.blossomMaxCount) {
      updatedBlossoms.removeAt(0);
    }

    emit(BlossomUpdated(updatedBlossoms));
    _saveBlossoms();
  }

  void clearBlossoms() {
    emit(const BlossomUpdated([]));
    _saveBlossoms();
  }
}
