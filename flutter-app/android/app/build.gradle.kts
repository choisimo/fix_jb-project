plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter.report.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // NDK 버전 명시적 설정

    compileOptions {
        // Core Library Desugaring 활성화
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter.report.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // 🔥 멀티덱스 활성화 - ClassNotFoundException 해결
        multiDexEnabled = true
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core Library Desugaring 라이브러리 추가
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
