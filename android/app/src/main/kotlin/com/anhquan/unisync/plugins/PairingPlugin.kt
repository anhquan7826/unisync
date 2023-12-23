package com.anhquan.unisync.plugins

import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.ChannelUtil

class PairingPlugin : UnisyncPlugin() {
    override val channelHandler: ChannelUtil.ChannelHandler = ChannelUtil.PairingChannel

    override val plugin: String = PLUGIN_PAIRING

    override fun stop() {}

    override fun onDeviceMessage(message: DeviceMessage) {
        channelHandler.invoke(
            ChannelUtil.PairingChannel.ON_DEVICE_PAIR_REQUEST
        )
    }

    override fun addChannelHandler() {

    }
}