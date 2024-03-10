package com.anhquan.unisync.core

import android.content.Context
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.core.plugins.battery.BatteryPlugin
import com.anhquan.unisync.core.plugins.clipboard.ClipboardPlugin
import com.anhquan.unisync.core.plugins.notification.NotificationPlugin
import com.anhquan.unisync.core.plugins.ring_phone.RingPhonePlugin
import com.anhquan.unisync.core.plugins.run_command.RunCommandPlugin
import com.anhquan.unisync.core.plugins.volume.VolumePlugin
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.infoLog
import io.reactivex.rxjava3.subjects.BehaviorSubject

class Device private constructor(
    val context: Context, val info: DeviceInfo
) : DeviceConnection.ConnectionListener {
    companion object {
        private val instances = mutableMapOf<DeviceInfo, Device>()

        fun of(context: Context, info: DeviceInfo): Device {
            if (instances.containsKey(info)) return instances[info]!!
            val device = Device(context, info)
            instances[info] = device
            return device
        }

        fun of(info: DeviceInfo): Device {
            return instances[info]!!
        }

        fun of(deviceId: String): Device {
            return instances[DeviceInfo(id = deviceId, name = "", deviceType = "")]!!
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
                disposePlugins()
                if (pairState != PairingHandler.PairState.PAIRED) {
                    instances.remove(info)
                }
            } else {
                infoLog("${this::class.simpleName}@${info.name}: Connected!")
                _connection!!.connectionListener = this
                initiatePlugins()
            }
            notify()
        }

    val isOnline: Boolean get() = pairingHandler.isReady && connection != null
    val pairState: PairingHandler.PairState get() = pairingHandler.state
    val pairOperation: PairingHandler.PairOperation get() = pairingHandler.operation

    private lateinit var plugins: List<UnisyncPlugin>
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
            BatteryPlugin(this),
            ClipboardPlugin(this),
            NotificationPlugin(this),
            VolumePlugin(this),
            RunCommandPlugin(this),
            RingPhonePlugin(this),
        )
    }

    private fun disposePlugins() {
        plugins.forEach {
            it.dispose()
        }
    }

    fun <T : UnisyncPlugin> getPlugin(type: Class<T>): T {
        return plugins.filterIsInstance(type).first()
    }

    val notifier = BehaviorSubject.create<Notification>()

    @JvmName("deviceNotify")
    private fun notify() {
        DeviceProvider.providerNotify()
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