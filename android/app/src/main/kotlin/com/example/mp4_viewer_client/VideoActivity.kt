package com.example.mp4_viewer_client

import android.os.Bundle
import android.util.Log
import androidx.activity.enableEdgeToEdge
import androidx.annotation.OptIn
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView

class VideoActivity : AppCompatActivity() {
    var player: ExoPlayer? = null
    lateinit var playerView: PlayerView
    lateinit var mediaItem: MediaItem

    private var startItemIndex = C.INDEX_UNSET
    private var startPosition: Long = C.TIME_UNSET


    fun initializePlayer(videoUrl: String): Boolean {
        if (player == null) {
            mediaItem = MediaItem.fromUri(videoUrl)
            val builder = ExoPlayer.Builder(this)
            player = builder.build()
            playerView.player = player
        }

        val haveStartPosition = startItemIndex != C.INDEX_UNSET
        if (haveStartPosition) {
            player!!.seekTo(startItemIndex, startPosition)
        }
        player!!.setMediaItem(mediaItem)
        player!!.prepare()
        return true
    }


    @OptIn(UnstableApi::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_video)
        val videoUrl = intent.getStringExtra("videoUrl")
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        player = ExoPlayer.Builder(this).build()
        playerView = findViewById(R.id.player_view)
        playerView.player = player
        playerView.useController = true

        playerView.controllerShowTimeoutMs = 0
        playerView.controllerHideOnTouch = false
        playerView.controllerAutoShow = true

        val mediaItem = MediaItem.fromUri(videoUrl!!)
        // Set the media item to be played.
        player!!.setMediaItem(mediaItem)
        // Prepare the player.
        player!!.prepare()
        // Start the playback.
        player!!.play()

        player!!.addListener(object : Player.Listener {
            override fun onIsLoadingChanged(isLoading: Boolean) {
                Log.d(VideoActivity::class.java.simpleName, "loading changed:$isLoading")
            }

            override fun onIsPlayingChanged(isPlaying: Boolean) {
                Log.d(VideoActivity::class.java.simpleName, "playing changed:$isPlaying")
            }

        })
    }

    override fun onResume() {
        super.onResume()
    }

    override fun onStop() {
        super.onStop()
        player!!.release()
    }
}