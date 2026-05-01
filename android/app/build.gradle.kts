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
    namespace = "com.example.comecomepay"
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
        applicationId = "com.comecomepay.app"
        minSdk = 23
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


        externalNativeBuild {
            cmake {
                // Enable 16 KB page size support for NDK r27
                arguments += "-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON"
            }
        }
    }

    signingConfigs {
        create("release") {
            println("DEBUG_SIGNING: Checking for key.properties at ${keystorePropertiesFile.absolutePath}")
            if (keystorePropertiesFile.exists()) {
                println("DEBUG_SIGNING: key.properties found. Loading signing config.")
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                val storePath = keystoreProperties["storeFile"] as String
                storeFile = file(storePath)
                storePassword = keystoreProperties["storePassword"] as String
                println("DEBUG_SIGNING: Using alias: $keyAlias, storeFile: ${storeFile?.absolutePath}")
            } else {
                println("DEBUG_SIGNING: key.properties NOT FOUND! Falling back to default signing (likely debug).")
            }
        }
    }

    buildTypes {
        release {
            // Use release signing configuration from key.properties
            signingConfig = signingConfigs.getByName("release")
            // signingConfig = signingConfigs.getByName("debug")

            // Enable code shrinking/obfuscation with custom keep rules.
            isMinifyEnabled = true
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    // Packaging options for 16 KB page size support
    packaging {
        jniLibs {
            // Use compressed (legacy) packaging to avoid 16 KB ZIP alignment
            // issues caused by pre-built third-party .so libraries.
            // This is compatible with all AGP versions and Google Play.
            useLegacyPackaging = true
        }

        // Ensure all native libraries are included
        pickFirsts += listOf(
            "**/libc++_shared.so",
            "**/libflutter.so"
        )
    }

    // NDK version is already set above; no duplicate needed.
    
    // Force rebuild of all native components
    tasks.whenTaskAdded {
        if (name.contains("merge") && name.contains("JniLibFolders")) {
            doFirst {
                println("Merging JNI libraries with 16 KB alignment support")
            }
        }
    }
}

flutter {
    source = "../.."
}
