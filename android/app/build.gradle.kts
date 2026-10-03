import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firma de la versión release.
// Si existe android/key.properties se firma con esa clave (la tuya).
// Si no existe, se usa la clave de depuración para poder compilar igual.
// Instrucciones en COMO_HACER_RELEASE.txt
val propiedadesFirma = Properties()
val archivoFirma = rootProject.file("key.properties")
val tieneFirma = archivoFirma.exists()
if (tieneFirma) {
    propiedadesFirma.load(FileInputStream(archivoFirma))
}

android {
    namespace = "com.entreturno.entrega_turno"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.entreturno.entrega_turno"
        // Android 7.0 (API 24) o superior. Es el mínimo que soportan Flutter y
        // los plugins usados (shared_preferences, path_provider, share_plus).
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (tieneFirma) {
            create("release") {
                keyAlias = propiedadesFirma["keyAlias"] as String
                keyPassword = propiedadesFirma["keyPassword"] as String
                storeFile = file(propiedadesFirma["storeFile"] as String)
                storePassword = propiedadesFirma["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (tieneFirma) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
