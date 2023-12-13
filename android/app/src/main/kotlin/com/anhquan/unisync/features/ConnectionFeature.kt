package com.anhquan.unisync.features

import com.anhquan.unisync.entry.DeviceEntryPoint
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.plugins.MdnsPlugin
import com.anhquan.unisync.plugins.SocketPlugin
import com.anhquan.unisync.plugins.UnisyncPlugin
import com.anhquan.unisync.utils.ChannelUtil
import com.anhquan.unisync.utils.ChannelUtil.ConnectionChannel.ON_DEVICE_CONNECTED
import com.anhquan.unisync.utils.ChannelUtil.ConnectionChannel.ON_DEVICE_DISCONNECTED
import com.anhquan.unisync.utils.listen
import com.anhquan.unisync.utils.toMap
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers

class ConnectionFeature : UnisyncFeature() {
    private val socketPluginHandler: SocketPlugin.SocketPluginHandler
        get() = pluginHandlers[UnisyncPlugin.PLUGIN_SOCKET] as SocketPlugin.SocketPluginHandler

    private val mdnsPluginHandler: MdnsPlugin.MdnsPluginHandler
        get() = pluginHandlers[UnisyncPlugin.PLUGIN_MDNS] as MdnsPlugin.MdnsPluginHandler

    override fun checkAvailability() {
        isAvailable = pluginHandlers.keys.containsAll(
            listOf(
                UnisyncPlugin.PLUGIN_MDNS,
                UnisyncPlugin.PLUGIN_SOCKET
            )
        )
    }

    override fun onFeatureReady() {
        DeviceEntryPoint.connectionNotifier.listen(observeOn = AndroidSchedulers.mainThread()) {
            when (it.state) {
                DeviceEntryPoint.DeviceState.ONLINE -> {
                    ChannelUtil.ConnectionChannel.invoke(
                        ON_DEVICE_CONNECTED,
                        args = mapOf(
                            "device" to toMap(it.deviceInfo)
                        )
                    )
                }

                DeviceEntryPoint.DeviceState.OFFLINE -> {
                    ChannelUtil.ConnectionChannel.invoke(
                        ON_DEVICE_DISCONNECTED,
                        args = mapOf(
                            "device" to toMap(it.deviceInfo)
                        )
                    )
                }

                else -> {}
            }
        }
    }

    override fun handlePluginData() {
        mdnsPluginHandler.apply {
            onServiceIpFound.listen {
                DeviceEntryPoint.createConnection(socketPluginHandler.getConnection(it))
            }
        }
    }

    override fun handleMethodChannelCall() {
        ChannelUtil.ConnectionChannel.apply {
            addCallHandler(GET_CONNECTED_DEVICES) { _, emitter ->
                emitter.success(getConnectedDevices().map { toMap(it) })
            }
            addCallHandler(ADD_DEVICE_MANUALLY) { args, emitter ->
                val ip = args!!["ip"].toString()
                val socketConnection = socketPluginHandler.getConnection(ip)
                DeviceEntryPoint.createConnection(socketConnection)
                emitter.success()
            }
        }
    }

    override fun handleDeviceMessage() {}

    private fun getConnectedDevices(): List<DeviceInfo> {
        return DeviceEntryPoint.getConnections().map { it.info }
    }
}