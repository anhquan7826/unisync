package com.anhquan.unisync.features

import com.anhquan.unisync.entry.DeviceEntryPoint
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.ChannelUtil
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.listen
import com.anhquan.unisync.utils.toMap

class PairingFeature : UnisyncFeature() {
    override fun checkAvailability() {
        isAvailable = true
    }

    override fun onFeatureReady() {}

    override fun handlePluginData() {}

    override fun handleMethodChannelCall() {
        ChannelUtil.PairingChannel.apply {
            addCallHandler(GET_PAIRED_DEVICES) { _, emitter ->
                getPairedDevices {
                    emitter.success(it.map { device -> toMap(device) })
                }
            }
            addCallHandler(SET_ACCEPT_PAIR) { args, emitter ->
                acceptPairRequest(args!!["id"].toString())
                emitter.success()
            }
            addCallHandler(SET_REJECT_PAIR) { args, emitter ->
                rejectPairRequest(args!!["id"].toString())
                emitter.success()
            }
            addCallHandler(SEND_PAIR_REQUEST) { args, emitter ->

            }
        }
    }

    override fun handleDeviceMessage() {
        DeviceEntryPoint.pairingNotifier.listen {

        }
    }

    private fun getPairedDevices(onComplete: (List<DeviceInfo>) -> Unit) {
        ConfigUtil.Device.getPairedDevices {
            val connectedDevices = DeviceEntryPoint.getConnections().map { connection -> connection.info }
            val devicesWithIP = it.map { device ->
                val info = connectedDevices.firstOrNull { info -> info.id == device.id }
                return@map if (info != null) {
                    // TODO: save this device if the persisted data is different (changed name or something else)
                    info
                } else {
                    device
                }
            }
            onComplete.invoke(devicesWithIP)
        }
    }

    private fun onDevicePairRequest(deviceID: String) {
        ChannelUtil.PairingChannel.invoke(
            ChannelUtil.PairingChannel.ON_DEVICE_PAIR_REQUEST,
            args = mapOf("id" to deviceID)
        )
    }

    private fun onDevicePairResponse(deviceID: String, accepted: Boolean) {
        ChannelUtil.PairingChannel.invoke(
            ChannelUtil.PairingChannel.ON_DEVICE_PAIR_RESPONSE,
            args = mapOf(
                "id" to deviceID,
                "accepted" to accepted
            )
        )
    }

    private fun acceptPairRequest(deviceID: String) {
        DeviceEntryPoint.getConnection(deviceID).sendMessage(
            DeviceMessage(
                messageType = DeviceMessage.RESPONSE,
                information = DeviceMessage.MessageInformation.Pairing.DEVICE_PAIR_RESULT,
                data = mapOf("accepted" to true)
            )
        )
    }

    private fun rejectPairRequest(deviceID: String) {
        DeviceEntryPoint.getConnection(deviceID).sendMessage(
            DeviceMessage(
                messageType = DeviceMessage.RESPONSE,
                information = DeviceMessage.MessageInformation.Pairing.DEVICE_PAIR_RESULT,
                data = mapOf("accepted" to true)
            )
        )
    }

    private fun sendPairRequest() {

    }
}