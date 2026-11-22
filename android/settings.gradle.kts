pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}

// Dynamic versions ("+") are intentional in this playground repository so
// that the latest plugin versions are always used, at the cost of
// reproducible builds.
plugins {
    id("com.android.application") version "9.5.1" apply false
    id("com.google.firebase.crashlytics") version "+" apply false
    id("com.google.gms.google-services") version "+" apply false
    id("dev.flutter.flutter-plugin-loader") version "+"
    id("org.gradle.toolchains.foojay-resolver-convention") version "+"
}

include(":app")
