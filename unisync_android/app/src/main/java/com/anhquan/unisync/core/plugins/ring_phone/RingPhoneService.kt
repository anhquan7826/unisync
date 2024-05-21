package com.anhquan.unisync.core.plugins.ring_phone

import android.app.Service
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.IBinder
import com.anhquan.unisync.R
import com.anhquan.unisync.utils.NotificationUtil

class RingPhoneService : Service() {
    private lateinit var mediaPlayer: MediaPlayer
    private lateinit var audioManager: AudioManager
    private var previousVolume = -1

    override fun onCreate() {
        super.onCreate()
        audioManager = getSystemService(AudioManager::class.java)
        try {
            mediaPlayer = MediaPlayer()
            val audioUri = Uri.parse("android.resource://$packageName/${R.raw.ringtone}")
            mediaPlayer.setDataSource(this, audioUri)
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_UNKNOWN)
                .setFlags(AudioAttributes.FLAG_AUDIBILITY_ENFORCED)
                .build()

            mediaPlayer.setAudioAttributes(audioAttributes)
            mediaPlayer.isLooping = true
            mediaPlayer.prepare()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = NotificationUtil.buildFindMyPhoneNotification(this)
        startForeground(5, notification)
        startPlaying()
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder?  = null

    override fun onDestroy() {
        stopPlaying()
        mediaPlayer.release()
        super.onDestroy()
    }

    private fun startPlaying() {
        if (!mediaPlayer.isPlaying) {
            // Make sure we are heard even when the phone is silent, restore original volume later
            previousVolume = audioManager.getStreamVolume(AudioManager.STREAM_ALARM)
            audioManager.setStreamVolume(
                AudioManager.STREAM_ALARM,
                audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM),
                0
            )
            mediaPlayer.start()
        }
    }

    private fun stopPlaying() {
        if (previousVolume != -1) {
            audioManager.setStreamVolume(AudioManager.STREAM_ALARM, previousVolume, 0)
        }
        mediaPlayer.stop()
    }
}