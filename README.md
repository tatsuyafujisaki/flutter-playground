# flutter-playground

A Flutter playground with examples and small demo pages (Google Maps,
LiveKit, and WebView) backed by Firebase.

## Setup

1. Install the Flutter SDK pinned in `.fvmrc` with [FVM](https://fvm.app):

   ```shell
   fvm install
   ```

2. Create `dart_defines.json` in the repository root. This file is ignored by
   Git.

   ```json
   {
     "GOOGLE_MAPS_PLATFORM_API_KEY": "<your-api-key>",
     "LIVEKIT_ROOM_NAME": "test",
     "APP_STORE_ID": "<numeric-app-store-id>"
   }
   ```

   | Key | Required | Description |
   |---|---|---|
   | `GOOGLE_MAPS_PLATFORM_API_KEY` | Yes | Google Maps API key. The Android build fails without it. |
   | `LIVEKIT_ROOM_NAME` | No | The default room name on the LiveKit page. Defaults to `test`. |
   | `APP_STORE_ID` | No | The App Store ID for the iOS force-update dialog. If it's not set, the dialog isn't shown on iOS. |

3. Generate the Firebase options with the
   [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup). This creates
   `lib/firebase_options_dev.dart` and `lib/firebase_options_prod.dart`, which are
   ignored by Git.

4. Get packages and generate code (Freezed, `json_serializable`, and Riverpod):

   ```shell
   fvm flutter pub get
   fvm dart run build_runner build --delete-conflicting-outputs
   ```

5. Run the app:

   ```shell
   fvm flutter run --flavor dev --dart-define-from-file=dart_defines.json
   ```

## Secrets

### Cloud Functions for Firebase

The `generateLiveKitToken` function in `functions/` needs the following
secrets:

```shell
firebase functions:secrets:set LIVEKIT_URL
firebase functions:secrets:set LIVEKIT_API_KEY
firebase functions:secrets:set LIVEKIT_API_SECRET
```

### GitHub Actions

CI needs the following repository secrets, which contain the Base64-encoded
Firebase options files:

| Secret | How to create it |
|---|---|
| `FIREBASE_OPTIONS_DEV_BASE64` | `base64 -i lib/firebase_options_dev.dart` |
| `FIREBASE_OPTIONS_PROD_BASE64` | `base64 -i lib/firebase_options_prod.dart` |

## Project structure

| Path | Contents |
|---|---|
| `bin/examples/` | Pure Dart examples that you run with `fvm dart run <file>`. |
| `lib/data/` | Models, repositories, wrappers, and utilities. |
| `lib/extension/` | Pure Dart extensions shared across layers. |
| `lib/ui/page/` | Demo pages reachable from `HomePage`. |
| `lib/ui/example/` | Flutter widget and package examples, mostly viewed as widget previews. |

Some code isn't used by the app and is kept as standalone snippets:
`StreamExtension`, `isDialogShowing`, `printLocales`, and `Debouncer`.

## Distribute an iOS app

```shell
rm -r build/ios # ensures *.ipa matches only the newly built file

fvm flutter build ipa --flavor prod --dart-define-from-file=dart_defines.json --export-method ad-hoc

# https://firebase.google.com/docs/app-distribution/ios/distribute-cli
firebase appdistribution:distribute \
  build/ios/ipa/*.ipa \
  --app <FIREBASE_APP_ID> \
  --release-notes-file release-notes.txt \
  --groups 'group1,group2'
```

## Distribute an Android app

```shell
rm -r build/app

fvm flutter build apk --flavor prod --dart-define-from-file=dart_defines.json # --release is the default, so no need to specify it.

# https://firebase.google.com/docs/app-distribution/android/distribute-cli
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-prod-release.apk \
  --app <FIREBASE_APP_ID> \
  --release-notes-file release-notes.txt \
  --groups 'group1,group2'
```
