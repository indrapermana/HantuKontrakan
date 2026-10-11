import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../simulation/models/game_state.dart';

abstract interface class SaveService {
  Future<GameState?> load();
  Future<void> save(GameState state);
}

class SharedPreferencesSaveService implements SaveService {
  static const _saveKey = 'hantu_kontrakan_p0_save';

  @override
  Future<GameState?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_saveKey);
    if (encoded == null) return null;
    try {
      final json = jsonDecode(encoded) as Map<String, Object?>;
      return GameState.fromJson(json);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(GameState state) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_saveKey, jsonEncode(state.toJson()));
  }
}

class MemorySaveService implements SaveService {
  GameState? storedState;

  @override
  Future<GameState?> load() async => storedState;

  @override
  Future<void> save(GameState state) async {
    storedState = GameState.fromJson(state.toJson());
  }
}
