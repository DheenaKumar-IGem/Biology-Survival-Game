import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { stream ->
        keystoreProperties.load(stream)
    }
}

val hasReleaseSigning = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword",
).all { key -> keystoreProperties[key]?.toString()?.isNotBlank() == true }

val releaseSigningProblem: String? = when {
    !hasReleaseSigning ->
        "Release signing is not configured. Copy android/key.properties.example to android/key.properties and fill in the private keystore values before building release."
    listOf("storePassword", "keyAlias", "keyPassword").any { key ->
        keystoreProperties[key]?.toString()?.trim() == "change-me"
    } ->
        "Release signing still contains placeholder values from android/key.properties.example."
    !file(keystoreProperties["storeFile"] as String).exists() ->
        "Release signing keystore was not found: ${keystoreProperties["storeFile"]}."
    else -> null
}

gradle.taskGraph.whenReady {
    val releaseTaskRequested = allTasks.any { task ->
        task.path.startsWith(":app:") &&
            task.name.contains("Release", ignoreCase = true)
    }
    if (releaseTaskRequested && releaseSigningProblem != null) {
        throw GradleException(releaseSigningProblem)
    }
}

android {
    namespace = "com.pdacimmune.pdac_immune_defense"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    defaultConfig {
        // Stable package id for Android installs.
        applicationId = "com.pdacimmune.pdac_immune_defense"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}
