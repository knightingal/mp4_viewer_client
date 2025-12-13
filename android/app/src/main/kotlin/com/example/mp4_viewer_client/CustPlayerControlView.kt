package com.example.mp4_viewer_client

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import androidx.annotation.OptIn
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.ui.PlayerControlView

@OptIn(UnstableApi::class)
class CustPlayerControlView (context: Context, attrs: AttributeSet?, defStyleAttr: Int, playbackAttrs: AttributeSet?)
    : PlayerControlView(context, attrs, defStyleAttr, playbackAttrs) {
    constructor(context: Context) : this(context, null)
    constructor(context: Context, attrs: AttributeSet?): this(context, attrs, 0)
    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int): this(context, attrs, defStyleAttr, attrs)

    private var dragStartPos: Float = 0f
    private var lastPosition: Long = 0
    private var width: Int = 0

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        super.onLayout(changed, left, top, right, bottom)
        width = right - left
    }

    override fun setPlayer(player: Player?) {
        super.setPlayer(player)

        findViewById<View>(R.id.cust_move_background).setOnTouchListener { v, event ->
            v.performClick()
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    getPlayer()!!.pause()
                    dragStartPos = event.x
                    lastPosition = getPlayer()!!.currentPosition
                }
                MotionEvent.ACTION_UP -> {
                    val xOffset = event.x - dragStartPos
                    val positionOffset = (getPlayer()!!.duration.toFloat() * xOffset / width.toFloat()).toLong()
                    getPlayer()!!.seekTo(lastPosition + positionOffset)
                    getPlayer()!!.play()
                }
                MotionEvent.ACTION_MOVE -> {
                    val xOffset = event.x - dragStartPos
                    val positionOffset = (getPlayer()!!.duration.toFloat() * xOffset / width.toFloat()).toLong()
                    getPlayer()!!.seekTo(lastPosition + positionOffset)
                }
            }
            true
        }
    }
}