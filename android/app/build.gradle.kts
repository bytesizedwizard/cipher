import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val releaseKeyAlias =
    System.getenv("ANDROID_KEY_ALIAS") ?: keystoreProperties["keyAlias"]?.toString()
val releaseKeyPassword =
    System.getenv("ANDROID_KEY_PASSWORD") ?: keystoreProperties["keyPassword"]?.toString()
val releaseStoreFile =
    System.getenv("ANDROID_STORE_FILE") ?: keystoreProperties["storeFile"]?.toString()
val releaseStorePassword =
    System.getenv("ANDROID_STORE_PASSWORD") ?: keystoreProperties["storePassword"]?.toString()
val releaseSigningAvailable =
    releaseKeyAlias != null &&
        releaseKeyPassword != null &&
        releaseStoreFile != null &&
        releaseStorePassword != null

if (gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) } &&
    !releaseSigningAvailable
) {
    throw GradleException(
        "Release signing is not configured. Provide android/key.properties or the ANDROID_* signing variables.",
    )
}

android {
    namespace = "dev.bytesizedwizard.cipherauth"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "dev.bytesizedwizard.cipherauth"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = releaseKeyAlias
            keyPassword = releaseKeyPassword
            storeFile = releaseStoreFile?.let { file(it) }
            storePassword = releaseStorePassword
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    
}

flutter {
    source = "../.."
}
