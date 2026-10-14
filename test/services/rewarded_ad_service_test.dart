import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/services/rewarded_ad_service.dart';

void main() {
  test('production adapter is pinned to Google rewarded test units', () {
    expect(
      GoogleTestRewardedAdService.androidTestUnitId,
      'ca-app-pub-3940256099942544/5224354917',
    );
    expect(
      GoogleTestRewardedAdService.iosTestUnitId,
      'ca-app-pub-3940256099942544/1712485313',
    );
  });

  test('platform manifests contain only Google sample app IDs', () {
    final android = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final ios = File('ios/Runner/Info.plist').readAsStringSync();

    expect(android, contains('ca-app-pub-3940256099942544~3347511713'));
    expect(ios, contains('ca-app-pub-3940256099942544~1458002511'));
  });
}
