package com.anhquan.unisync.core

import android.content.Context
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.core.plugins.clipboard.ClipboardPlugin
import com.anhquan.unisync.core.plugins.gallery.GalleryPlugin
import com.anhquan.unisync.core.plugins.notification.NotificationPlugin
import com.anhquan.unisync.core.plugins.ring_phone.RingPhonePlugin
import com.anhquan.unisync.core.plugins.run_command.RunCommandPlugin
import com.anhquan.unisync.core.plugins.sharing.SharingPlugin
import com.anhquan.unisync.core.plugins.ssh.SSHPlugin
import com.anhquan.unisync.core.plugins.status.StatusPlugin
import com.anhquan.unisync.core.plugins.storage.StoragePlugin
import com.anhquan.unisync.core.plugins.telephony.TelephonyPlugin
import com.anhquan.unisync.core.plugins.volume.VolumePlugin
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.infoLog
import io.reactivex.rxjava3.subjects.PublishSubject

class Device private constructor(
    val context: Context,
    val info: DeviceInfo
) : DeviceConnection.ConnectionListener {
    companion object {
        data class InstantNotifyValue(
            val added: Boolean, val instance: Device
        )

        private val instances = mutableMapOf<DeviceInfo, Device>()
        val instanceNotifier = PublishSubject.create<InstantNotifyValue>()

        fun of(context: Context, info: DeviceInfo): Device {
            if (instances.containsKey(info)) return instances[info]!!
            val device = Device(context, info)
            instances[info] = device
            instanceNotifier.onNext(
                InstantNotifyValue(
                    added = true, instance = device
                )
            )
            return device
        }

        fun of(deviceId: String): Device {
            return instances[DeviceInfo(id = deviceId, name = "", deviceType = "")]!!
        }

        private fun removeInstance(info: DeviceInfo) {
            val device = instances.remove(info)
            if (device != null) {
                instanceNotifier.onNext(
                    InstantNotifyValue(
                        added = true, instance = device
                    )
                )
            }
        }

        fun getAllDevices(context: Context, callback: (List<Device>) -> Unit) {
            ConfigUtil.Device.getAllPairedDevices {
                it.forEach { info -> of(context, info) }
                callback(instances.values.toList())
            }
        }

        fun getConnectedDevices(): List<Device> {
            return instances.values.filter {
                it.isOnline
            }
        }
    }

    val ipAddress: String? get() = _connection?.ipAddress
    private var _connection: DeviceConnection? = null

    var connection: DeviceConnection?
        get() = _connection
        set(value) {
            _connection = value
            if (value == null) {
                infoLog("${this::class.simpleName}@${info.name}: Disconnected!")
                if (pairingHandler.state != PairingHandler.PairState.PAIRED) {
                    removeInstance(info)
                }
            } else {
                _connection!!.connectionListener = this
                infoLog("${this::class.simpleName}@${info.name}: Connected!")
                if (pairState == PairingHandler.PairState.MARK_UNPAIRED) {
                    pairOperation.unpair()
                }
            }
            notifyNewEvent()
        }

    val isOnline: Boolean get() = pairingHandler.isReady && connection != null
    val pairState: PairingHandler.PairState get() = pairingHandler.state
    val pairOperation: PairingHandler.PairOperation get() = pairingHandler.operation

    var plugins: List<UnisyncPlugin> = listOf()
        private set

    private val pairingHandler = PairingHandler(this) {
        notifyNewEvent()
    }

    override fun onMessage(message: DeviceMessage, payload: DeviceConnection.Payload?) {
        infoLog("${this::class.simpleName}@${info.name}: Message received${if (message.payload != null) " with payload" else ""}:\n$message")
        if (message.type == DeviceMessage.Type.PAIR) {
            pairingHandler.handle(message)
        } else if (pairingHandler.state == PairingHandler.PairState.PAIRED) {
            plugins.forEach { plugin ->
                if (plugin.type == message.type) {
                    plugin.onReceive(message, payload)
                }
            }
        }
    }

    override fun onDisconnected() {
        connection = null
    }

    fun sendMessage(
        message: DeviceMessage,
        payload: DeviceConnection.Payload? = null,
        onProgress: ((Float) -> Unit)? = null
    ) {
        if (pairingHandler.state == PairingHandler.PairState.PAIRED || message.type == DeviceMessage.Type.PAIR) {
            connection?.send(message, payload, onProgress)
            infoLog("${this::class.simpleName}@${info.name}: Message sent:\n$message")
        }
    }

    private fun initiatePlugins() {
        plugins = listOf(
            StatusPlugin(this),
            ClipboardPlugin(this),
            NotificationPlugin(this),
            VolumePlugin(this),
            RunCommandPlugin(this),
            RingPhonePlugin(this),
            TelephonyPlugin(this),
            SharingPlugin(this),
            GalleryPlugin(this),
            StoragePlugin(this),
            SSHPlugin(this)
        )
    }

    private fun disposePlugins() {
        for (plugin in plugins) {
            plugin.onDispose()
        }
    }

    fun <T : UnisyncPlugin> getPlugin(type: Class<T>): T {
        return plugins.filterIsInstance(type).first()
    }

    private val listeners = mutableListOf<DeviceEventListener>()

    fun addEventListener(listener: DeviceEventListener) {
        listeners.add(listener)
        listener.onDeviceEvent(
            DeviceEvent(
                connected = isOnline, pairState = pairState
            )
        )
    }

    fun removeEventListener(listener: DeviceEventListener) {
        listeners.remove(listener)
    }

    private fun notifyNewEvent() {

        if (isOnline && pairState == PairingHandler.PairState.PAIRED) {
            initiatePlugins()
            informListeners()
        } else {
            informListeners()
            disposePlugins()
        }
    }

    private fun informListeners() {
        for (listener in listeners) {
            listener.onDeviceEvent(
                DeviceEvent(
                    connected = isOnline, pairState = pairState
                )
            )
        }
    }

    data class DeviceEvent(
        val connected: Boolean = true,
        val pairState: PairingHandler.PairState = PairingHandler.PairState.UNKNOWN
    )

    interface DeviceEventListener {
        fun onDeviceEvent(event: DeviceEvent)
    }
}