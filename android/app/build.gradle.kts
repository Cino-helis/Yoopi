plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ← Pas de version ici, elle vient du buildscript
}

android {
    namespace = "com.example.yoopi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion  // ← Corrigez le typo (89373993 → 8937393)

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"  // ← Changez de 1.8 à 17 (cohérence avec compileOptions)
    }

    defaultConfig {
        applicationId = "com.example.yoopi"
        minSdk = flutter.minSdkVersion  // ← Mettez 23 directement (requis pour Firebase)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}
