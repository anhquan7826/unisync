package com.anhquan.unisync.plugins

import com.anhquan.unisync.core.providers.DeviceProvider
import com.anhquan.unisync.models.ChannelResult
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.models.DeviceMessage.Pairing
import com.anhquan.unisync.utils.ChannelUtil
import com.anhquan.unisync.utils.ChannelUtil.PairingChannel
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.toJson

class PairingPlugin : UnisyncPlugin() {
    override val channelHandler: ChannelUtil.ChannelHandler = PairingChannel

    override val plugin: String = PLUGIN_PAIRING

    private val requestedPairStack = mutableListOf<DeviceInfo>()

    override fun onDeviceMessage(message: DeviceMessage) {
        if (message.plugin == plugin) {
            when (message.function) {
                Pairing.REQUEST_PAIR -> {
                    onIncomingPairRequest(message.fromDeviceId)
                }

                Pairing.PAIR_ACCEPTED -> {
                    onPairRequestAccepted(message.fromDeviceId)
                }

                Pairing.PAIR_REJECTED -> {
                    onPairRequestRejected(message.fromDeviceId)
                }
            }
        }
    }

    private fun onIncomingPairRequest(deviceId: String) {
        requestedPairStack.removeIf { d -> d.id == deviceId }
        requestedPairStack.add(
            0,
            DeviceProvider.devices.first { d -> d.id == deviceId }
        )
        channelHandler.invoke(
            PairingChannel.ON_DEVICE_PAIR_REQUEST,
            args = mapOf("id" to deviceId)
        )
    }

    private fun onPairRequestAccepted(deviceId: String) {
        ConfigUtil.Device.addPairedDevice(DeviceProvider.devices.first { d -> d.id == deviceId })
        channelHandler.invoke(
            PairingChannel.ON_DEVICE_PAIR_RESPONSE,
            args = mapOf(
                "id" to deviceId,
                "response" to true
            )
        )
    }

    private fun onPairRequestRejected(deviceId: String) {
        channelHandler.invoke(
            PairingChannel.ON_DEVICE_PAIR_RESPONSE,
            args = mapOf(
                "id" to deviceId,
                "response" to false
            )
        )
    }

    override fun addChannelHandler() {
        channelHandler.apply {
            addCallHandler(PairingChannel.SEND_PAIR_REQUEST) { args, emitter ->
                sendPairRequestTo(args!!["id"].toString())
                emitter.emit(ChannelResult.SUCCESS)
            }
            addCallHandler(PairingChannel.SET_ACCEPT_PAIR) { args, emitter ->
                acceptPairFrom(args!!["id"].toString())
                emitter.emit(ChannelResult.SUCCESS)
            }
            addCallHandler(PairingChannel.SET_REJECT_PAIR) { args, emitter ->
                rejectPairFrom(args!!["id"].toString())
                emitter.emit(ChannelResult.SUCCESS)
            }
            addCallHandler(PairingChannel.GET_PAIRED_DEVICES) { _, emitter ->
                ConfigUtil.Device.getPairedDevices {
                    emitter.emit(ChannelResult.SUCCESS, result = it.map { d -> toJson(d) })
                }
            }
        }
    }

    private fun sendPairRequestTo(deviceId: String) {
        send(
            toDeviceId = deviceId,
            function = Pairing.REQUEST_PAIR,
        )
    }

    private fun acceptPairFrom(deviceId: String) {
        send(toDeviceId = deviceId, function = Pairing.PAIR_ACCEPTED)
        ConfigUtil.Device.addPairedDevice(DeviceProvider.devices.first { d -> d.id == deviceId })
        requestedPairStack.removeIf { d -> d.id == deviceId }
    }

    private fun rejectPairFrom(deviceId: String) {
        send(toDeviceId = deviceId, function = Pairing.PAIR_REJECTED)
        requestedPairStack.removeIf { d -> d.id == deviceId }
    }
}