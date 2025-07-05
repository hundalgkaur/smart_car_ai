plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase plugin
    id("kotlin-android")
    // Flutter Gradle Plugin (must come last)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Set the namespace for your application (AGP 7.0+ does not use the package attribute in AndroidManifest.xml)
    namespace = "com.example.smart_car_ai_alert"   // Use your desired package name

    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Ensure this matches the required NDK version for your dependencies

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.smart_car_ai_alert"  // Your app's application ID (should match the namespace)
        minSdk = 23  // Manually set to meet plugin requirements
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // Optional: Use debug signing config for easier testing
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."  // Path to the Flutter module
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7")
    implementation("androidx.core:core-ktx:1.9.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    // Add other dependencies as needed
}
