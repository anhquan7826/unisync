package com.anhquan.unisync.core.device

import android.content.Context
import com.anhquan.unisync.core.device.dependencies.DeviceConnection
import com.anhquan.unisync.core.device.dependencies.PairingHandler
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.core.plugins.battery.BatteryPlugin
import com.anhquan.unisync.core.plugins.clipboard.ClipboardPlugin
import com.anhquan.unisync.core.plugins.notification.NotificationPlugin
import com.anhquan.unisync.core.plugins.ring_phone.RingPhonePlugin
import com.anhquan.unisync.core.plugins.run_command.RunCommandPlugin
import com.anhquan.unisync.core.plugins.volume.VolumePlugin
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage

class Device(
    private val context: Context, private val connection: DeviceConnection, val info: DeviceInfo
) : DeviceConnection.ConnectionListener, DeviceConnection.ConnectionEmitter {
    private val plugins: List<UnisyncPlugin>
    private val pairingHandler = PairingHandler(this)

    init {
        connection.addMessageListener(this)
        connection.deviceInfo = info
        plugins = listOf(
            BatteryPlugin(context, this),
            ClipboardPlugin(context, this),
            NotificationPlugin(context, this),
            VolumePlugin(context, this),
            RunCommandPlugin(context, this),
            RingPhonePlugin(context, this),
        )
    }

    val pairOperation: PairingHandler.PairOperation get() = pairingHandler.operation

    val pairState: PairingHandler.PairState
        get() {
            return pairingHandler.state
        }

    override fun onConnection() {

    }

    override fun onMessage(message: DeviceMessage) {
        pairingHandler.onMessageReceived(message)
        if (pairingHandler.state == PairingHandler.PairState.PAIRED) {
            plugins.forEach { plugin ->
                if (plugin.isPluginMessage(message)) {
                    plugin.onMessageReceived(message)
                }
            }
        }
    }

    override fun onDisconnection() {
        plugins.forEach {
            it.dispose()
        }
    }

    override fun sendMessage(message: DeviceMessage) {
        if (pairingHandler.state == PairingHandler.PairState.PAIRED || message.type == DeviceMessage.Type.PAIR) {
            connection.send(message)
        }
    }

    fun <T : UnisyncPlugin> getPlugin(type: Class<T>): T {
        return plugins.filterIsInstance(type).first()
    }
}