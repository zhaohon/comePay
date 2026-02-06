import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load key.properties for signing configuration
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.Demo"
    // Override Flutter's default compileSdk to use API 35 so that new
    // predictive back APIs like android.window.BackEvent are available
    // on the compile classpath for R8.
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.Demo.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // Load local.properties to get flutter version info
        val localProperties = Properties()
        val localPropertiesFile = rootProject.file("local.properties")
        if (localPropertiesFile.exists()) {
            localProperties.load(FileInputStream(localPropertiesFile))
        }

        val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toIntOrNull()
            ?: project.findProperty("flutter.versionCode")?.toString()?.toIntOrNull()
            ?: 1

        val flutterVersionName = localProperties.getProperty("flutter.versionName")
            ?: project.findProperty("flutter.versionName")?.toString()
            ?: "1.0.0"
        
        println("DEBUG_GRADLE: flutter.versionName resolved to = $flutterVersionName")

        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use release signing configuration from key.properties
            // signingConfig = signingConfigs.getByName("release")
            signingConfig = signingConfigs.getByName("debug")

            // Enable code shrinking/obfuscation with custom keep rules.
            isMinifyEnabled = true
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}
