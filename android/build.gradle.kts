buildscript {
    repositories {
        google()  // ใช้ในโปรเจคทั้งหมด
        mavenCentral()
    }
    dependencies {
        classpath "com.android.tools.build:gradle:7.0.3"
        classpath "com.google.gms:google-services:4.4.3"  // เพิ่มบรรทัดนี้สำหรับ Firebase
    }
}

allprojects {
    repositories {
        google()  // ใช้ในโปรเจคทั้งหมด
        mavenCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
