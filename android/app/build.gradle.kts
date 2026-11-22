import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun getDartDefine(key: String): String? {
    val dartDefines = project.findProperty("dart-defines") as? String
    if (dartDefines != null) {
        val match = dartDefines.split(",")
            .map { Base64.getDecoder().decode(it).decodeToString() }
            .find { it.startsWith("$key=") }
            ?.substringAfter("$key=")
        if (match != null) return match
    }
    return localProperties.getProperty(key)
}

android {
    namespace = "com.tatsuyafujisaki.flutterplayground"
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

        manifestPlaceholders["GOOGLE_MAPS_PLATFORM_API_KEY"] = getDartDefine("GOOGLE_MAPS_PLATFORM_API_KEY")
            ?: throw GradleException("GOOGLE_MAPS_PLATFORM_API_KEY is not set.")
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
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
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

flutter {
    source = "../.."
}
