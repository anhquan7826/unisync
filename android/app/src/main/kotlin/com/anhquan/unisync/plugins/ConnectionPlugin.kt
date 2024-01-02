package com.anhquan.unisync.plugins

import com.anhquan.unisync.core.DeviceDiscovery
import com.anhquan.unisync.core.providers.ConnectionProvider
import com.anhquan.unisync.models.ChannelResult
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.utils.ChannelUtil
import com.anhquan.unisync.utils.ChannelUtil.ConnectionChannel
import com.anhquan.unisync.utils.ChannelUtil.ConnectionChannel.ADD_DEVICE_MANUALLY
import com.anhquan.unisync.utils.ChannelUtil.ConnectionChannel.GET_CONNECTED_DEVICES
import com.anhquan.unisync.utils.ChannelUtil.ConnectionChannel.ON_DEVICE_CONNECTED
import com.anhquan.unisync.utils.ChannelUtil.ConnectionChannel.ON_DEVICE_DISCONNECTED
import com.anhquan.unisync.utils.toJson
import com.anhquan.unisync.utils.toMap

class ConnectionPlugin : UnisyncPlugin() {
    override val channelHandler: ChannelUtil.ChannelHandler = ConnectionChannel
    override val plugin: String = PLUGIN_CONNECTION

    override fun addChannelHandler() {
        channelHandler.addCallHandler(
            ADD_DEVICE_MANUALLY
        ) { args, emitter ->
            DeviceDiscovery.connectToAddress(args!!["ip"].toString())
            emitter.emit(
                resultCode = ChannelResult.SUCCESS
            )
        }
        channelHandler.addCallHandler(
            GET_CONNECTED_DEVICES
        ) { _, emitter ->
            emitter.emit(
                resultCode = ChannelResult.SUCCESS,
                result = ConnectionProvider.devices.map { toJson(it) }
            )
        }
    }

    override fun onDeviceConnected(info: DeviceInfo) {
        channelHandler.invoke(
            ON_DEVICE_CONNECTED,
            args = mapOf(
                "device" to toMap(info)
            )
        )
    }

    override fun onDeviceDisconnected(info: DeviceInfo) {
        channelHandler.invoke(
            ON_DEVICE_DISCONNECTED,
            args = mapOf(
                "device" to toMap(info)
            )
        )
    }
}