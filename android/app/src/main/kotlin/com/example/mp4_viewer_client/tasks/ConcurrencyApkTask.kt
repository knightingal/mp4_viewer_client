package com.example.mp4_viewer_client.tasks

import android.util.Log
import com.example.mp4_viewer_client.AboutActivity
//import io.ktor.client.HttpClient
//import io.ktor.client.call.body
//import io.ktor.client.engine.okhttp.OkHttp
//import io.ktor.client.request.get
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.Response
import okio.Buffer
import okio.BufferedSource
import okio.ForwardingSource
import okio.buffer
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

object ConcurrencyApkTask {
    private const val TAG = "DLImageTask"

    private fun makeClient(listener: AboutActivity.DownloadCounterListener) : HttpClient = HttpClient(OkHttp) {
        engine {
            addNetworkInterceptor { chain ->
                val originalResponse: Response = chain.proceed(chain.request())
                val body = originalResponse.body
                val wrappedBody = ResponseBodyListener(body!!, listener)
                originalResponse.newBuilder().body(wrappedBody).build()
            }
        }
    }

    suspend fun downloadToFile(src: String, dest: File, listener: AboutActivity.DownloadCounterListener) {
        return withContext(Dispatchers.IO) {
            Log.d(TAG, "start download $src")

//            val client = makeClient(listener)
//            while (true) {
//                try {
//                    val bytes: ByteArray = client.get(src).body()
//                    val fileOutputStream = FileOutputStream(dest, false)
//                    fileOutputStream.write(bytes)
//                    fileOutputStream.close()
//                    break
//                } catch (e: IOException) {
//                    e.printStackTrace()
//                    Log.e(TAG, "download $src error")
//                }
//            }

        }

    }
}

class ByteCounter(val totalBytes: Long, val listener: AboutActivity.DownloadCounterListener) {
    var bytesReadSoFar: Long = 0
    fun update(bytesRead: Long) {
        bytesReadSoFar += bytesRead
        val progress = bytesReadSoFar * 100 / totalBytes
        println("download progress: $progress% ($bytesReadSoFar/$totalBytes)")
        listener.update(bytesReadSoFar, totalBytes)
    }
}

class ResponseBodyListener(val origin: okhttp3.ResponseBody, listener: AboutActivity.DownloadCounterListener): okhttp3.ResponseBody() {
    val byteCounter = ByteCounter(contentLength(), listener)

    override fun contentLength(): Long {
        return origin.contentLength() ?: 0
    }

    private var bufferedSource: BufferedSource? = null

    override fun contentType(): okhttp3.MediaType? {
        return origin.contentType()
    }

    override fun source(): okio.BufferedSource {
        if (bufferedSource ==null) {
            bufferedSource = source(origin.source()).buffer()
        }
        return bufferedSource!!
    }

    private fun source(source: okio.Source): okio.Source {
        return object : ForwardingSource(source) {
            override fun read(sink: Buffer, byteCount: Long): Long {
                val bytesRead = super.read(sink, byteCount)
                println("bytesRead: $bytesRead")
                if (bytesRead >= 0) {
                    byteCounter.update(bytesRead)
                }
                return bytesRead
            }
        }
    }

}
