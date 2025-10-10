plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin para leer google-services.json
    id("com.google.gms.google-services")
}

android {
    // Debe coincidir con el package del JSON y con el applicationId
    namespace = "com.napphy.services"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // Debe coincidir exactamente con el package_name del google-services.json
        applicationId = "com.napphy.services"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Firma de debug temporal para poder ejecutar en release
            signingConfig = signingConfigs.getByName("debug")
            // Si usas ProGuard/R8, puedes añadir reglas aquí más adelante
            // isMinifyEnabled = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Desugaring para APIs de Java más nuevas
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}
