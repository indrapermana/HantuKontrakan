# Android Closed Test Checklist

## Locally prepared

- [x] Branded 1024×1024 icon and generated Android launcher sizes.
- [x] Localized Indonesian and English app/store copy.
- [x] In-app localized privacy summary and privacy-policy entry.
- [x] Canonical publishable privacy-policy Markdown and Data safety inputs documented.
- [x] Android application ID set to `com.indesyakaryadigital.hantu_kontrakan`.
- [x] Production AdMob setup procedure documented.
- [x] Flame game area verified on a physical iPhone after fixing the nested-world render defect.
- [x] Non-debug gameplay and settings screenshots captured from a physical-iPhone profile build.
- [x] Debug signing removed from the Android release build type.
- [x] Unsigned release bundle compilation checked locally.

## Owner actions before Play upload

- [ ] Confirm a valid Apple-compatible iOS bundle ID; Apple does not permit `_` in bundle IDs.
- [ ] Create or select the Play Console app record.
- [ ] Enroll in Play App Signing and provide the upload keystore outside version control.
- [ ] Add secure signing configuration and produce a signed `.aab`.
- [ ] Publish `PRIVACY_POLICY.md` at a stable public HTTPS URL and add that URL to the stores.
- [ ] Replace Google sample ad IDs with production IDs and validate UMP/rewarded ads on Android.
- [ ] Complete the Ads and Data safety declarations, including Google Mobile Ads/UMP SDK behavior.
- [ ] Upload final non-debug phone screenshots and store icon.
- [ ] Configure the closed track, tester list, countries, content rating, target audience, and app access declarations.
- [ ] Install the Play-delivered build from the closed track and run the offline/save/ad-consent smoke test.

## Build command after signing is configured

```sh
flutter build appbundle --release
```

Do not upload a debug-signed artifact. The locally compiled unsigned bundle is build evidence only, not a functioning closed-beta package.
