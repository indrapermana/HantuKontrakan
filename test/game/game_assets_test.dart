import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/game/assets/game_assets.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'all ghost atlases are bundled transparent normalized 4x4 sheets',
    () async {
      expect(GameAssets.ghostAtlases.keys.toSet(), GhostKind.values.toSet());

      for (final path in GameAssets.ghostAtlases.values) {
        final data = await rootBundle.load('assets/images/$path');
        final bytes = data.buffer.asUint8List();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();

        expect(frame.image.width, 1448, reason: path);
        expect(frame.image.height, 1084, reason: path);
        expect(frame.image.width % 4, 0, reason: path);
        expect(frame.image.height % 4, 0, reason: path);
        expect(bytes[25], 6, reason: '$path must remain RGBA PNG');

        frame.image.dispose();
        codec.dispose();
      }
    },
  );

  test('cutaway, UI coin, and selected WAV files are bundled', () async {
    final cutaway = await rootBundle.load(
      'assets/images/${GameAssets.cutaway}',
    );
    final coin = await rootBundle.load(GameAssets.spiritCoin);
    final settings = await rootBundle.load(GameAssets.settingsIcon);
    expect(cutaway.lengthInBytes, greaterThan(1000));
    expect(coin.lengthInBytes, greaterThan(1000));
    expect(settings.lengthInBytes, greaterThan(1000));

    for (final path in <String>[
      GameAssets.backgroundMusic,
      GameAssets.tensionMusic,
      ...GameAssets.audioEffects.values,
    ]) {
      final data = await rootBundle.load('assets/$path');
      final bytes = data.buffer.asUint8List();
      expect(ascii.decode(bytes.sublist(0, 4)), 'RIFF', reason: path);
      expect(ascii.decode(bytes.sublist(8, 12)), 'WAVE', reason: path);
    }

    final music = (await rootBundle.load(
      'assets/${GameAssets.backgroundMusic}',
    )).buffer.asByteData();
    expect(music.getUint16(22, Endian.little), 1);
    expect(music.getUint32(24, Endian.little), 32000);
    expect(music.getUint16(34, Endian.little), 16);
    final dataLength = music.getUint32(40, Endian.little);
    expect(dataLength / (32000 * 2), greaterThanOrEqualTo(150));
    for (var offset = 44; offset < 76; offset += 2) {
      expect(music.getInt16(offset, Endian.little).abs(), lessThanOrEqualTo(1));
    }
    for (
      var offset = music.lengthInBytes - 32;
      offset < music.lengthInBytes;
      offset += 2
    ) {
      expect(music.getInt16(offset, Endian.little).abs(), lessThanOrEqualTo(1));
    }
  });

  test(
    'asset manifest documents rows, sources, and excluded currencies',
    () async {
      final manifest =
          jsonDecode(await rootBundle.loadString('assets/asset_manifest.json'))
              as Map<String, Object?>;
      final atlases = manifest['ghostAtlases']! as Map<String, Object?>;

      expect(atlases['rowOrder'], ['idle', 'happy', 'angry', 'special']);
      expect(manifest['excludedSheetConcepts'], containsAll(['Rp', 'cash']));
      expect(manifest['sourceNotes'], isA<Map<String, Object?>>());
      final audio = manifest['audio']! as Map<String, Object?>;
      final suite = audio['generatedSuite']! as Map<String, Object?>;
      expect(suite['durationSeconds'], greaterThanOrEqualTo(150));
      expect(audio['effects'], isA<List<Object?>>());
      expect(
        (audio['effects']! as List<Object?>).length,
        greaterThanOrEqualTo(30),
      );
    },
  );
}
