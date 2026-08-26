package com.example.mp4_viewer_client

import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.core.net.toUri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter/startWeb"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->

            if (call.method == "startWeb") {
                val url: String? = call.arguments()
                startWeb(url)
            }
            if (call.method == "aboutPage") {
                val intent = Intent(this, AboutActivity::class.java)
                startActivity(intent)
            }
            if (call.method == "startVideo") {
                val videoUrl = call.argument<String>("videoUrl")
                val intent = Intent(this, VideoActivity::class.java)
                intent.putExtra("videoUrl", videoUrl)
                startActivity(intent)
            }
            if (call.method == "viewPdf") {
                val pdfUrl = call.argument<String>("pdfUrl")
                val uri = pdfUrl!!.toUri()
                val intent = Intent(Intent.ACTION_VIEW, uri)
                startActivity(intent)
            }
        }
    }

    fun startWeb(url: String?) {
        Log.d("CHANNEL", "" + url)
        val intent = Intent()
        intent.action = "android.intent.action.VIEW"
        val uri = url!!.toUri()
        intent.data = uri
        startActivity(intent)
    }
}
