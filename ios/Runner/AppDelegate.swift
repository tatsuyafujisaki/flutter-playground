import Flutter
import GoogleMaps
import OSLog
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, @MainActor FlutterImplicitEngineDelegate {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.tatsuyafujisaki.poc",
        category: "AppDelegate"
    )

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Get the Google Maps API key from the Info.plist
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_PLATFORM_API_KEY") as? String {
            if !apiKey.isEmpty && apiKey != "$(GOOGLE_MAPS_PLATFORM_API_KEY)" {
                GMSServices.provideAPIKey(apiKey)
                Self.logger.info("Successfully provided Google Maps API Key.")
            } else {
                Self.logger.warning(
                    "GOOGLE_MAPS_PLATFORM_API_KEY was found in Info.plist, but its value is either empty or the placeholder '$(GOOGLE_MAPS_PLATFORM_API_KEY)'. Check your Xcode build configuration and dart_defines.json."
                )
            }
        } else {
            Self.logger.error(
                "GOOGLE_MAPS_PLATFORM_API_KEY key not found in the app's Info.plist at all. Check that the key exists in ios/Runner/Info.plist."
            )
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: any FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }
}
