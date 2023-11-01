package com.anhquan.unisync.features

import com.anhquan.unisync.plugins.MdnsPlugin
import com.anhquan.unisync.plugins.SocketPlugin
import com.anhquan.unisync.plugins.UnisyncPlugin
import com.anhquan.unisync.utils.ChannelUtil
import com.anhquan.unisync.utils.listen
import com.anhquan.unisync.utils.toMap

class PairingFeature : UnisyncFeature() {
    private val socketPluginHandler: SocketPlugin.SocketPluginHandler
        get() = handlers[UnisyncPlugin.PLUGIN_SOCKET] as SocketPlugin.SocketPluginHandler

    private val mdnsPluginHandler: MdnsPlugin.MdnsPluginHandler
        get() = handlers[UnisyncPlugin.PLUGIN_MDNS] as MdnsPlugin.MdnsPluginHandler

    override fun checkAvailability() {
        isAvailable = handlers.keys.containsAll(
            listOf(
                UnisyncPlugin.PLUGIN_MDNS,
                UnisyncPlugin.PLUGIN_SOCKET
            )
        )
    }

    override fun handlePluginData() {
        mdnsPluginHandler.apply {
            onServiceIpFound.listen {
                configureDeviceConnection(socketPluginHandler.getConnection(it))
            }
        }
    }

    override fun handleMethodChannelCall() {
        ChannelUtil.PairingChannel.apply {
            addCallHandler(GET_DISCOVERED_DEVICES) { _, result ->
                result.success(DeviceConnection.getUnpairedDevices().map { toMap(it) })
            }
        }
    }

    private fun configureDeviceConnection(socket: SocketPlugin.SocketConnection) {
        DeviceConnection.createConnection(socket)
    }
}