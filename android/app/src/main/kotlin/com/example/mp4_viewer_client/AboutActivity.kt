package com.example.mp4_viewer_client

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.Environment
import android.provider.Settings
import android.util.Log
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.core.content.FileProvider
import com.example.jianming.Tasks.ConcurrencyApkTask
import com.example.jianming.Tasks.ConcurrencyJsonApiTask
import com.example.mp4_viewer_client.bean.ApkConfig
import com.google.gson.Gson
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import java.io.File

const val SERVER_IP = "192.168.2.12"

const val SERVER_PORT = "3002"
class AboutActivity : AppCompatActivity() {
    private var versionCode: Long = 0

    private lateinit var apkFile: File
    @RequiresApi(Build.VERSION_CODES.P)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_about)
        val versionCodeText = findViewById<TextView>(R.id.version_code)
        val versionNameText = findViewById<TextView>(R.id.version_name)
        val imageView = findViewById<ImageView>(R.id.image_view_logo)
        val packageManager = packageManager

        try {
            val packageInfo = packageManager.getPackageInfo(packageName, 0)
            val versionName = packageInfo.versionName
            versionNameText.text = versionName
            versionCode = packageInfo.longVersionCode
            versionCodeText.text = versionCode.toString()
        } catch (e: PackageManager.NameNotFoundException) {
            throw RuntimeException(e)
        }

        imageView.setOnClickListener {
            val pendingUrl = "http://${SERVER_IP}:${SERVER_PORT}/apkConfig/newest/package/${packageName}"
            MainScope().launch {
                val respBody = ConcurrencyJsonApiTask.makeRequest(pendingUrl)
                val apkConfig = Gson().fromJson(respBody, ApkConfig::class.java)

                Log.d("about", apkConfig.toString())
                Log.i("about", "currVersion:$versionCode, newestVersion: ${apkConfig.versionCode}")
                if (apkConfig.versionCode > versionCode) {
                    Toast.makeText(this@AboutActivity, "you have newer apk", Toast.LENGTH_LONG).show()
                    val directory = File(this@AboutActivity.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS), "apk")
                    apkFile = File(directory, apkConfig.apkName)
                    directory.mkdirs()
                    ConcurrencyApkTask.makeRequest(apkConfig.downloadUrl, apkFile)

                    if (getPackageManager().canRequestPackageInstalls()) {
                        openAPKFile()
                    } else {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse(
                                "package:$packageName"
                            )
                        )
                        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        startActivityForResult(intent, 101)
//                        launcher.launch(intent)
                    }
                } else {
                    Toast.makeText(this@AboutActivity, "you are in newest apk", Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 101 && resultCode == RESULT_OK) {
            openAPKFile()
        } else {
            Toast.makeText(this@AboutActivity,
                "you did not grant the permission",
                Toast.LENGTH_LONG)
                .show()
        }
    }

    private fun openAPKFile() {
        val mimeDefault = "application/vnd.android.package-archive"
        Log.d("file", "file path: ${apkFile.toString()}")
        try {
            val intent = Intent(Intent.ACTION_VIEW)
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            val contentUri = FileProvider.getUriForFile(
                this@AboutActivity,
                "com.example.mp4_viewer_client.file_provider",
                apkFile
            )
            intent.setDataAndType(contentUri, mimeDefault)
            startActivity(intent)
        } catch (e: Throwable) {
            e.printStackTrace()
        }
    }
}