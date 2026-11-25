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
     "GOOGLE_MAPS_ANDROID_API_KEY": "<your-android-api-key>",
     "GOOGLE_MAPS_IOS_API_KEY": "<your-ios-api-key>",
     "LIVEKIT_ROOM_NAME": "test",
     "APP_STORE_ID": "<numeric-app-store-id>"
   }
   ```

   | Key | Required | Description |
   |---|---|---|
   | `GOOGLE_MAPS_ANDROID_API_KEY` | Yes (Android) | Google Maps API key restricted to Android apps and to Maps SDK for Android only. The Android build fails without it. |
   | `GOOGLE_MAPS_IOS_API_KEY` | Yes (iOS) | Google Maps API key restricted to iOS bundle IDs and to Maps SDK for iOS only. |
   | `LIVEKIT_ROOM_NAME` | No | The default room name on the LiveKit page. Defaults to `test`. |
   | `APP_STORE_ID` | No | The App Store ID for the iOS force-update dialog. If it's not set, the dialog isn't shown on iOS. |

   The Google Maps API keys are embedded in the app because the Maps SDKs
   require them, so don't allow any other API on them. The Places API key stays
   on the server. See
   [Cloud Functions for Firebase](#cloud-functions-for-firebase).

3. Generate the Firebase options with the
   [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup). This creates
   `lib/firebase_options_dev.dart` and `lib/firebase_options_prod.dart`, which are
   ignored by Git.

4. Get packages and generate code (Freezed, `json_serializable`, and Riverpod):

   ```shell
   fvm flutter pub get
   fvm dart run build_runner build
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

The `searchNearbyChainCafes` function in `functions/` needs the following
secret. Its value is a Google Maps API key that has no application restriction
and is restricted to Places API (New) only:

```shell
firebase functions:secrets:set GOOGLE_PLACES_API_KEY
```

### App Check

The app sends [App Check](https://firebase.google.com/docs/app-check) tokens,
but `searchNearbyChainCafes` enforces them only when the `ENFORCE_APP_CHECK`
environment variable is `true`. To turn on enforcement for a Firebase project:

1. In the Firebase console, go to **App Check** and register the Android app
   with Play Integrity and the iOS app with DeviceCheck.
2. For debug builds, run the app, copy the debug token that it logs, and add
   the token under **Manage debug tokens**.
3. Create `functions/.env.<project-id>`, which is ignored by Git, with the
   following content, and then deploy the functions:

   ```shell
   ENFORCE_APP_CHECK=true
   ```

### GitHub Actions

CI needs the following repository secrets, which contain the Base64-encoded
Firebase options files:

| Secret | How to create it |
|---|---|
| `FIREBASE_OPTIONS_DEV_BASE64` | `base64 -i lib/firebase_options_dev.dart` |
| `FIREBASE_OPTIONS_PROD_BASE64` | `base64 -i lib/firebase_options_prod.dart` |
