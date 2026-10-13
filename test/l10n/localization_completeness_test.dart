import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/features/home/detail_sheets.dart';
import 'package:hantu_kontrakan/l10n/app_localizations.dart';
import 'package:hantu_kontrakan/simulation/content/furniture_definitions.dart';
import 'package:hantu_kontrakan/simulation/content/ghost_definitions.dart';

void main() {
  test('Indonesian and English ARB catalogs have identical nonempty keys', () {
    Map<String, Object?> readCatalog(String path) =>
        jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

    final indonesian = readCatalog('lib/l10n/app_id.arb');
    final english = readCatalog('lib/l10n/app_en.arb');
    final indonesianKeys = indonesian.keys
        .where((key) => !key.startsWith('@'))
        .toSet();
    final englishKeys = english.keys
        .where((key) => !key.startsWith('@'))
        .toSet();

    expect(indonesianKeys, englishKeys);
    for (final key in indonesianKeys) {
      expect((indonesian[key] as String).trim(), isNotEmpty, reason: key);
      expect((english[key] as String).trim(), isNotEmpty, reason: key);
    }
  });

  test('all furniture and preference tags resolve in both languages', () {
    final catalogs = [
      lookupAppLocalizations(const Locale('id')),
      lookupAppLocalizations(const Locale('en')),
    ];
    final tags = GhostDefinitions.all.values
        .expand((ghost) => ghost.preferredRoomTags)
        .toSet();

    for (final catalog in catalogs) {
      for (final furnitureId in FurnitureDefinitions.all.keys) {
        expect(
          localizedFurniture(catalog, furnitureId).trim(),
          isNotEmpty,
          reason: '${catalog.localeName}/$furnitureId',
        );
      }
      for (final tag in tags) {
        expect(
          localizedTag(catalog, tag).trim(),
          isNotEmpty,
          reason: '${catalog.localeName}/$tag',
        );
      }
    }
  });
}
