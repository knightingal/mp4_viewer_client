package com.example.mp4_viewer_client.tasks

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

object ConcurrencyApkTask {
    private const val TAG = "DLImageTask"
    fun downloadUrl(src: String, dest: File, callback: (bytes: ByteArray) -> Unit): Unit {
        MainScope().launch {
            val bytes = makeRequest(src, dest)
            if (bytes != null) {
                callback(bytes)
            }
        }
    }

    suspend fun makeRequest(src: String, dest: File): ByteArray? {
        return withContext(Dispatchers.IO) {
            Log.d(TAG, "start download $src")
            val request = Request.Builder().url(src).build()
            var bytes: ByteArray?
            while (true) {
                try {
                    bytes = OkHttpClient().newBuilder().build().newCall(request).execute().body.bytes()
                    val fileOutputStream = FileOutputStream(dest, false)
                    fileOutputStream.write(bytes)
                    fileOutputStream.close()
                    break
                } catch (e: IOException) {
                    e.printStackTrace()
                    Log.e(TAG, "download $src error")
                }
            }
            bytes

        }

    }
}