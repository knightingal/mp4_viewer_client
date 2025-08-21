import java.io.BufferedReader
import java.io.FileInputStream
import java.io.InputStreamReader
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Properties
import okhttp3.OkHttpClient
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.Request
import okhttp3.RequestBody.Companion.asRequestBody

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
buildscript {
    dependencies{

        classpath("com.squareup.okhttp3:okhttp:5.0.0-alpha.11")
    }
}

var keystorePropertiesFile = rootProject.file("../../keys/keystore.properties")
var keystoreProperties = Properties()
keystoreProperties.load(FileInputStream(keystorePropertiesFile))

android {
    ndkVersion = "27.0.12077973"
    signingConfigs {
        getByName("debug") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    namespace = "com.example.mp4_viewer_client"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.mp4_viewer_client"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = versionCode()
        versionName = "${releaseTime()}-${commitNum()}"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
fun String.execute(): Process {
    val runtime = Runtime.getRuntime()
    return runtime.exec(this)
}

fun Process.text(): String {
    val inputStream = this.inputStream
    val insReader = InputStreamReader(inputStream)
    val bufReader = BufferedReader(insReader)
    var output = ""
    var line: String = ""
    line = bufReader.readLine()
    output += line
    return output
}

fun releaseTime(): String = SimpleDateFormat("yyMMdd").format(Date())

fun versionCode(): Int = SimpleDateFormat("yyMMdd0HH").format(Date()).toInt()
//fun versionCode(): Int = 10

fun commitNum(): String {
    val resultArray = "git describe --always".execute().text().trim().split("-")
    return resultArray[resultArray.size - 1]
}

task("releaseUpload") {
    dependsOn("assembleRelease")
    doLast {
        println("do releaseUpload")
        val target = "${project.buildDir}/outputs/apk/release/app-release.apk"
        println(target)
        val client:OkHttpClient = OkHttpClient().newBuilder().build();
        val body = MultipartBody.Builder().setType(MultipartBody.FORM)
            .addFormDataPart("file", target,
                File(target).asRequestBody("application/octet-stream".toMediaTypeOrNull())
            )
            .build()
        val request = Request.Builder()
            .url("http://localhost:8000/apkConfig/upload")
            .method("POST", body)
            .build()
        val response = client.newCall(request).execute()
        println("${response.code.toString()}  ${response.body.string()}")
    }
}
dependencies {
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("com.google.code.gson:gson:2.10.1")
    implementation("com.squareup.okhttp3:okhttp:5.0.0-alpha.11")
}