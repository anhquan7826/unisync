package com.anhquan.unisync.core

import android.content.Context
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.core.plugins.clipboard.ClipboardPlugin
import com.anhquan.unisync.core.plugins.notification.NotificationPlugin
import com.anhquan.unisync.core.plugins.ring_phone.RingPhonePlugin
import com.anhquan.unisync.core.plugins.run_command.RunCommandPlugin
import com.anhquan.unisync.core.plugins.status.StatusPlugin
import com.anhquan.unisync.core.plugins.telephony.TelephonyPlugin
import com.anhquan.unisync.core.plugins.volume.VolumePlugin
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.infoLog
import io.reactivex.rxjava3.subjects.BehaviorSubject
import io.reactivex.rxjava3.subjects.PublishSubject

class Device private constructor(
    val info: DeviceInfo
) : DeviceConnection.ConnectionListener {
    companion object {
        data class InstantNotifyValue(
            val added: Boolean, val instance: Device
        )

        private val instances = mutableMapOf<DeviceInfo, Device>()
        val instanceNotifier = PublishSubject.create<InstantNotifyValue>()

        fun of(info: DeviceInfo): Device {
            if (instances.containsKey(info)) return instances[info]!!
            val device = Device(info)
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

        fun getAllDevices(callback: (List<Device>) -> Unit) {
            ConfigUtil.Device.getAllPairedDevices {
                it.forEach { info -> of(info) }
                callback(instances.values.toList())
            }
        }
    }

    val ipAddress: String? get() = _connection?.ipAddress
    private var _connection: DeviceConnection? = null

    val context: Context? get() = _connection?.context

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
                infoLog("${this::class.simpleName}@${info.name}: Connected!")
                _connection!!.connectionListener = this
            }
            notify()
        }

    val isOnline: Boolean get() = pairingHandler.isReady && connection != null
    val pairState: PairingHandler.PairState get() = pairingHandler.state
    val pairOperation: PairingHandler.PairOperation get() = pairingHandler.operation

    private var plugins: List<UnisyncPlugin> = listOf()
    private val pairingHandler = PairingHandler(this) {
        notify()
    }

    override fun onMessage(message: DeviceMessage) {
        infoLog("${this::class.simpleName}@${info.name}: Message received:\n$message")
        if (message.type == DeviceMessage.Type.PAIR) {
            pairingHandler.handle(message.body)
        } else if (pairingHandler.state == PairingHandler.PairState.PAIRED) {
            plugins.forEach { plugin ->
                if (plugin.type == message.type) {
                    plugin.onReceive(message.body)
                }
            }
        }
    }

    override fun onDisconnected() {
        connection = null
    }

    fun sendMessage(message: DeviceMessage) {
        if (pairingHandler.state == PairingHandler.PairState.PAIRED || message.type == DeviceMessage.Type.PAIR) {
            connection?.send(message)
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
            TelephonyPlugin(this)
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

    val notifier = BehaviorSubject.create<Notification>()

    @JvmName("deviceNotify")
    private fun notify() {
        debugLog("${info.name}\nisOnline: $isOnline\nisPaired: $pairState");
        if (isOnline && pairState == PairingHandler.PairState.PAIRED) {
            initiatePlugins()
        } else {
            disposePlugins()
        }
        notifier.onNext(
            Notification(
                connected = isOnline, pairState = pairState
            )
        )
    }

    data class Notification(
        val connected: Boolean = true,
        val pairState: PairingHandler.PairState = PairingHandler.PairState.UNKNOWN
    )
}