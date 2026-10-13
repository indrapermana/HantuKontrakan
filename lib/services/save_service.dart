import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../simulation/models/game_state.dart';

enum SaveRejectionReason { corrupt, unsupportedVersion }

sealed class SaveLoadResult {
  const SaveLoadResult();
}

final class SaveNotFound extends SaveLoadResult {
  const SaveNotFound();
}

final class SaveLoaded extends SaveLoadResult {
  const SaveLoaded(this.state);

  final GameState state;
}

final class SaveRejected extends SaveLoadResult {
  const SaveRejected({required this.reason, this.schemaVersion});

  final SaveRejectionReason reason;
  final int? schemaVersion;
}

abstract interface class SaveService {
  Future<SaveLoadResult> load();
  Future<void> save(GameState state);
}

class SharedPreferencesSaveService implements SaveService {
  static const saveKey = 'hantu_kontrakan_p0_save';
  static const rejectedSaveBackupKey = 'hantu_kontrakan_rejected_save_backup';

  @override
  Future<SaveLoadResult> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(saveKey);
    if (encoded == null) return const SaveNotFound();

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Save root must be a JSON object.');
      }
      return SaveLoaded(GameState.fromJson(decoded));
    } on UnsupportedSaveVersion catch (error) {
      await _backupRejectedSave(preferences, encoded);
      return SaveRejected(
        reason: SaveRejectionReason.unsupportedVersion,
        schemaVersion: error.version,
      );
    } on Object {
      await _backupRejectedSave(preferences, encoded);
      return const SaveRejected(reason: SaveRejectionReason.corrupt);
    }
  }

  Future<void> _backupRejectedSave(
    SharedPreferences preferences,
    String encoded,
  ) async {
    await preferences.setString(rejectedSaveBackupKey, encoded);
  }

  @override
  Future<void> save(GameState state) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(saveKey, jsonEncode(state.toJson()));
  }
}

class MemorySaveService implements SaveService {
  MemorySaveService({SaveLoadResult initialResult = const SaveNotFound()})
    : _result = initialResult;

  SaveLoadResult _result;

  GameState? get storedState => switch (_result) {
    SaveLoaded(:final state) => state,
    _ => null,
  };

  SaveLoadResult get storedResult => _result;

  @override
  Future<SaveLoadResult> load() async => _result;

  @override
  Future<void> save(GameState state) async {
    _result = SaveLoaded(GameState.fromJson(state.toJson()));
  }
}
