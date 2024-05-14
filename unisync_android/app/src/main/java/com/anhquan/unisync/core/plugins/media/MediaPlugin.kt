package com.anhquan.unisync.core.plugins.media

import android.content.ComponentName
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.provider.Settings
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.core.plugins.notification.NotificationReceiver
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.runSingle
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers

class MediaPlugin(
    device: Device
) : UnisyncPlugin(device, DeviceMessage.Type.MEDIA),
    MediaSessionManager.OnActiveSessionsChangedListener {
    private val mediaManager = context.getSystemService(MediaSessionManager::class.java)
    private var registered: Boolean = false

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
                    registered = true
                }
            }
        }
    }

    override fun onDispose() {
        mediaManager.removeOnActiveSessionsChangedListener(this)
        super.onDispose()
    }

    private var currentMediaController: MediaController? = null

    override fun onActiveSessionsChanged(controllers: MutableList<MediaController>?) {
        controllers?.firstOrNull()?.apply {
            debugLog("metadata:")
            debugLog(this.metadata?.getString(MediaMetadata.METADATA_KEY_TITLE))
            debugLog(this.metadata?.getString(MediaMetadata.METADATA_KEY_ARTIST))
            registerCallback(object : MediaController.Callback() {
                override fun onPlaybackStateChanged(state: PlaybackState?) {
                    debugLog(state)
                }

                override fun onMetadataChanged(metadata: MediaMetadata?) {
                    debugLog("on metadata changed:")
                    debugLog(metadata)
                }

                override fun onSessionDestroyed() {
                    debugLog("destroyed")
                }
            })
        }
    }
}