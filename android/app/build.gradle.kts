plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // เพิ่มปลั๊กอิน Firebase
}

android {
    namespace = "com.example.easycrop"  // เปลี่ยนจาก "com.example.easy_crop_1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.easycrop"  // เปลี่ยนเป็นชื่อแพ็คเกจใหม่ที่นี่
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Firebase BoM (Bill of Materials) เพื่อให้ใช้เวอร์ชันที่เหมาะสมของ Firebase SDK
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))

    // เพิ่ม Firebase SDK ที่ต้องการใช้
    implementation("com.google.firebase:firebase-analytics")  // ตัวอย่าง Firebase Analytics
    implementation("com.google.firebase:firebase-auth")  // ตัวอย่าง Firebase Authentication
    // ถ้าต้องการใช้ Firebase Firestore หรือฟีเจอร์อื่น ๆ ก็ให้เพิ่ม dependencies ที่นี่
}
