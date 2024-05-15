package com.anhquan.unisync.core.plugins.media

import android.content.ComponentName
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.provider.Settings
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.core.plugins.notification.NotificationReceiver
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.convertBitmapToByteArray
import com.anhquan.unisync.utils.runSingle
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers

class MediaPlugin(
    device: Device
) : UnisyncPlugin(device, DeviceMessage.Type.MEDIA),
    MediaSessionManager.OnActiveSessionsChangedListener {
    private val mediaManager = context.getSystemService(MediaSessionManager::class.java)
    private var registered: Boolean = false

    object Method {
        const val SESSION_CHANGED = "session_changed"
        const val SESSION_PROGRESS_CHANGED = "session_progress_changed"
        const val SESSION_DISPOSED = "session_disposed"
        const val PLAY_PAUSE = "play_pause"
        const val SKIP_NEXT = "skip_next"
        const val SKIP_PREVIOUS = "skip_previous"
        const val SEEK = "seek"
    }

    init {
        registerMediaSession()
    }

    override val requiredPermission: List<String>
        get() {
            val notificationListenerList = Settings.Secure.getString(
                context.contentResolver, "enabled_notification_listeners"
            )
            return listOf("enabled_notification_listeners").filterNot {
                notificationListenerList.contains(context.packageName)
            }
        }

    fun registerMediaSession() {
        if (!registered) {
            runSingle(subscribeOn = AndroidSchedulers.mainThread()) {
                if (hasPermission) {
                    mediaManager.addOnActiveSessionsChangedListener(
                        this, ComponentName(context, NotificationReceiver::class.java)
                    )
                    onActiveSessionsChanged(
                        activeSessions
                    )
                    registered = true
                }
            }
        }
    }

    private val activeSessions: MutableList<MediaController>
        get() {
            return mediaManager.getActiveSessions(
                ComponentName(
                    context, NotificationReceiver::class.java
                )
            )
        }

    override fun listen(
        header: DeviceMessage.DeviceMessageHeader,
        data: Map<String, Any?>,
        payload: DeviceConnection.Payload?
    ) {
        super.listen(header, data, payload)
        when (header.method) {
            Method.PLAY_PAUSE -> {
                currentMediaController?.apply {
                    if (this.playbackState?.state == PlaybackState.STATE_PLAYING) {
                        transportControls.pause()
                    } else if (listOf(
                            PlaybackState.STATE_PAUSED, PlaybackState.STATE_STOPPED
                        ).contains(this.playbackState?.state)
                    ) {
                        transportControls.play()
                    }
                }
            }

            Method.SKIP_NEXT -> {
                currentMediaController?.apply {
                    transportControls.skipToNext()
                }
            }

            Method.SKIP_PREVIOUS -> {
                currentMediaController?.apply {
                    transportControls.skipToPrevious()
                }
            }

            Method.SEEK -> {
                currentMediaController?.apply {
                    val pos = (data["position"] as Double).toLong()
                    transportControls.seekTo(pos)
                }
            }
        }
    }

    override fun onDispose() {
        mediaManager.removeOnActiveSessionsChangedListener(this)
        super.onDispose()
    }

    private var currentMediaController: MediaController? = null

    private val mediaCallback = object : MediaController.Callback() {
        override fun onPlaybackStateChanged(state: PlaybackState?) {
            state?.apply { notifySessionProgressChanged(this) }
        }

        override fun onMetadataChanged(metadata: MediaMetadata?) {
            metadata?.apply { notifySessionChanged(this) }
        }

        override fun onSessionDestroyed() {
            notifySessionDisposed()
        }
    }

    override fun onActiveSessionsChanged(controllers: MutableList<MediaController>?) {
        if (controllers == null) return
        if (controllers.isEmpty()) {
            notifySessionDisposed()
        }
        controllers.firstOrNull()?.let {
            currentMediaController?.unregisterCallback(mediaCallback)
            currentMediaController = it
            it.metadata?.apply { notifySessionChanged(this) }
            it.registerCallback(mediaCallback)
        }
    }

    private fun notifySessionChanged(metadata: MediaMetadata) {
        sendNotification(method = Method.SESSION_CHANGED, data = mapOf(
            "id" to metadata.getString(MediaMetadata.METADATA_KEY_MEDIA_ID),
            "title" to metadata.getString(MediaMetadata.METADATA_KEY_TITLE),
            "artist" to (metadata.getString(MediaMetadata.METADATA_KEY_ARTIST)
                ?: metadata.getString(MediaMetadata.METADATA_KEY_AUTHOR) ?: metadata.getString(
                    MediaMetadata.METADATA_KEY_COMPOSER
                )),
            "album" to metadata.getString(MediaMetadata.METADATA_KEY_ALBUM),
            "duration" to metadata.getLong(MediaMetadata.METADATA_KEY_DURATION),
        ), payload = metadata.let {
            val bitmap = it.getBitmap(
                MediaMetadata.METADATA_KEY_ALBUM_ART
            ) ?: it.getBitmap(MediaMetadata.METADATA_KEY_ART)
            val bytes = convertBitmapToByteArray(bitmap) ?: return@let null
            DeviceConnection.Payload(bytes.inputStream(), bytes.size)
        })
    }

    private fun notifySessionProgressChanged(state: PlaybackState) {
        sendNotification(
            Method.SESSION_PROGRESS_CHANGED, mapOf(
                "state" to state.state,
                "position" to state.position,
            )
        )
    }

    private fun notifySessionDisposed() {
        currentMediaController = null
        sendNotification(
            Method.SESSION_DISPOSED, mapOf()
        )
    }
}