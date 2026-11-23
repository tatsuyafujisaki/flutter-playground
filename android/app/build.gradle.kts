import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

// Values passed with --dart-define or --dart-define-from-file.
fun getDartDefine(key: String): String? =
    providers.gradleProperty("dart-defines").orNull
        ?.split(",")
        ?.map { Base64.getDecoder().decode(it).decodeToString() }
        ?.find { it.startsWith("$key=") }
        ?.substringAfter("$key=")

android {
    namespace = "com.tatsuyafujisaki.poc"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion
    // https://developer.android.com/build/jdks#toolchain
    // https://kotlinlang.org/docs/gradle-configure-project.html#gradle-java-toolchains-support
    java.toolchain.languageVersion = JavaLanguageVersion.of(21)

    defaultConfig {
        applicationId = "com.tatsuyafujisaki.poc"
        minSdk = 37
        targetSdk = 37
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["GOOGLE_MAPS_ANDROID_API_KEY"] = getDartDefine("GOOGLE_MAPS_ANDROID_API_KEY")
            ?: throw GradleException(
                "GOOGLE_MAPS_ANDROID_API_KEY is not set. Pass --dart-define-from-file=dart_defines.json.",
            )
    }

    flavorDimensions += "app"

    productFlavors {
        create("dev") {
            dimension = "app"
            applicationIdSuffix = ".dev"
        }
        create("prod") {
            dimension = "app"
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            val releaseSigningConfig = signingConfigs.getByName("release")
            signingConfig = if (releaseSigningConfig.storeFile?.exists() == true) {
                releaseSigningConfig
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}
