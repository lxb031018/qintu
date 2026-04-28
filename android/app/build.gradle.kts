plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 读取 .env 文件获取环境变量
// Flutter 项目根目录: D:\AllCodes\qintu
val envFile = File("D:\\AllCodes\\qintu\\.env")
val envMap = mutableMapOf<String, String>()
if (envFile.exists()) {
    envFile.readLines().forEach { line ->
        val trimmed = line.trim()
        if (trimmed.isNotEmpty() && !trimmed.startsWith("#")) {
            val parts = trimmed.split("=", limit = 2)
            if (parts.size == 2) {
                envMap[parts[0].trim()] = parts[1].trim()
            }
        }
    }
}

android {
    namespace = "me.lxb.qintu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "me.lxb.qintu"
        minSdk = 28 // android 9.0 以上
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appLabel"] = "亲途"
        // 高德地图 API Key（优先从 .env 文件读取）
        manifestPlaceholders["AMAP_ANDROID_API_KEY"] = envMap["AMAP_ANDROID_API_KEY"]
            ?: System.getenv("AMAP_ANDROID_API_KEY")
            ?: ""
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appLabel"] = "亲途(调试)"
        }
        release {
            signingConfig = signingConfigs.getByName("debug")
            manifestPlaceholders["appLabel"] = "亲途"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 高德地图 Android SDK - 使用本地 jar
    implementation(files("libs/AMap3DMap_11.1.001_AMapNavi_11.1.001_AMapSearch_9.7.4_AMapLocation_11.1.001_20260402.jar"))
    // 语音播报需要的 MSC.jar
    implementation(files("libs/Msc.jar"))
    // AndroidX AppCompat（NavigationActivity 需要）
    implementation("androidx.appcompat:appcompat:1.1.0")
    // LocalBroadcastManager（导航状态传递需要）
    implementation("androidx.localbroadcastmanager:localbroadcastmanager:1.0.0")
}
