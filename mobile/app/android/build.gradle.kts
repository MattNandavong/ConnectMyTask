plugins {
    id("com.android.application") version "8.7.0"
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services") version "4.4.2" apply false
}

android {
    namespace = "com.connectmytask.app" // Replace with your actual package name
    compileSdk = 34

    defaultConfig {
        applicationId = "com.connectmytask.app"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.10")
    // Add other dependencies like Firebase, Retrofit, etc.
}

// Optional: move this below if you still need it for folder structure
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}
