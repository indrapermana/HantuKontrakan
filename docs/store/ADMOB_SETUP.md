# Hantu Kontrakan AdMob Production Setup

This project already integrates Google Mobile Ads, Google UMP consent, and one optional rewarded-ad flow. It currently uses Google's sample app IDs and rewarded test-unit IDs. Keep those test identifiers until the production AdMob setup and test-device validation below are complete.

## Identifiers you will need

Create separate values for each platform:

| Platform | AdMob app ID | Rewarded ad unit ID |
| --- | --- | --- |
| Android | `ca-app-pub-…~…` | `ca-app-pub-…/…` |
| iOS | `ca-app-pub-…~…` | `ca-app-pub-…/…` |

An app ID contains `~`; an ad unit ID contains `/`. Do not put an ad unit ID in a platform manifest.

## 1. Finish the store identities first

1. Use Android application ID `com.indesyakaryadigital.hantu_kontrakan`.
2. Confirm a valid iOS bundle identifier in Apple Developer/App Store Connect. Apple bundle IDs cannot contain `_`, so the requested Android identifier cannot be copied to iOS unchanged.
3. Do not change either identifier after its store record has received a build.

## 2. Create the AdMob apps

1. Sign in at <https://admob.google.com>.
2. Open **Apps → Add app**.
3. Add Hantu Kontrakan once for Android and once for iOS.
4. Until the store listings exist, select the unpublished/not-listed option.
5. Record each platform's AdMob **app ID**.
6. After the store listings are available, link each AdMob app to its store entry.

## 3. Create rewarded ad units

For each platform app:

1. Open **Ad units → Add ad unit**.
2. Select **Rewarded**.
3. Use a clear name such as `android_rewarded_rent` or `ios_rewarded_rent`.
4. Configure the console reward as a whole-number Spirit Coin reward. The game remains authoritative for its actual saved reward and duplicate protection.
5. Review frequency capping. The game currently enforces its own daily rewarded-rent limit, but console capping can add another restriction.
6. Create the unit and record its rewarded **ad unit ID**.

## 4. Replace the platform app IDs

Android: replace the Google sample value in:

`android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-ANDROID_PUBLISHER_ID~ANDROID_APP_ID" />
```

iOS: replace the Google sample value in:

`ios/Runner/Info.plist`

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-IOS_PUBLISHER_ID~IOS_APP_ID</string>
```

## 5. Replace rewarded unit IDs safely

The current test IDs are in `lib/services/rewarded_ad_service.dart`. Before inserting production values:

1. Rename `GoogleTestRewardedAdService` to `GoogleRewardedAdService` and update its call sites/tests.
2. Keep Google's rewarded test IDs for debug/profile builds.
3. Supply production Android/iOS rewarded unit IDs only to release builds, preferably through `--dart-define` or generated, uncommitted release configuration.
4. Make release startup fail closed to `RewardedAdOutcome.unavailable` when a production ID is absent; never silently use a live ID during development.
5. Never commit AdMob account credentials. App IDs and ad unit IDs are identifiers rather than secrets, but separating release configuration prevents accidental live-ad testing.

Suggested release build inputs:

```sh
flutter build appbundle --release \
  --dart-define=ADMOB_ANDROID_REWARDED_ID=ca-app-pub-REPLACE/REPLACE
```

Add an equivalent `ADMOB_IOS_REWARDED_ID` value to the iOS release workflow.

## 6. Configure consent and privacy

1. In AdMob, open **Privacy & messaging** and configure the required European regulations message and any other region-specific messages.
2. Verify that Google UMP can request consent and reopen privacy options on a physical device.
3. Keep rewarded collection available only when UMP reports that ads may be requested.
4. Update `PRIVACY_POLICY.md`, the website policy, and store Data safety/App Privacy answers if the chosen advertising configuration changes actual data processing.

## 7. Test without invalid traffic

1. Use Google's sample rewarded IDs during normal development:
   - Android: `ca-app-pub-3940256099942544/5224354917`
   - iOS: `ca-app-pub-3940256099942544/1712485313`
2. To test your own production unit configuration, register each physical device as an AdMob test device first.
3. Confirm that every served test ad displays the **Test Ad** label where applicable.
4. Never click live ads during development or QA.
5. Test consent granted, consent denied, no network, ad unavailable, dismissal before reward, successful reward, and the daily reward cap.
6. Confirm one completed impression grants the saved bonus exactly once across backgrounding and reload.

## 8. Complete release-side declarations

1. Publish the privacy policy at a public HTTPS URL.
2. Complete Google Play **Ads**, **Data safety**, target-audience, and content declarations from actual SDK behavior.
3. Complete Apple's **App Privacy** answers from the same behavior.
4. Publish `app-ads.txt` on the developer website using the exact publisher line supplied by AdMob, then verify it in AdMob.
5. Link the published store entries to AdMob and wait for app-readiness review.

## 9. Final verification

1. Build a signed release candidate.
2. Install it through the Play closed track or TestFlight—not directly from a debug build.
3. Verify UMP, privacy options, rewarded-ad loading, one-time reward delivery, offline fallback, and save/reload.
4. Recheck that no Google sample app ID or rewarded test ID remains in the distributed artifact.
