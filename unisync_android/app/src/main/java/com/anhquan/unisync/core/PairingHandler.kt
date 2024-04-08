package com.anhquan.unisync.core

import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.ConfigUtil

class PairingHandler(private val device: Device, private val onStateChanged: (PairState) -> Unit) {
    interface PairOperation {
        fun requestPair()

        fun unpair()
    }

    val operation = object : PairOperation {
        override fun requestPair() {
            if (state == PairState.NOT_PAIRED) {
                device.sendMessage(
                    DeviceMessage(
                        type = DeviceMessage.Type.PAIR, body = mapOf(
                            "message" to "requested"
                        )
                    )
                )
                state = PairState.REQUESTED
                onStateChanged(state)
            }
        }

        override fun unpair() {
            if (state == PairState.PAIRED) {
                ConfigUtil.Device.removePairedDevice(device.info)
                device.sendMessage(
                    DeviceMessage(
                        type = DeviceMessage.Type.PAIR, body = mapOf(
                            "message" to "unpair"
                        )
                    )
                )
                state = PairState.NOT_PAIRED
                onStateChanged(state)
            }
        }
    }

    init {
        ConfigUtil.Device.getDeviceInfo(device.info.id) { info, markUnpaired ->
            state = if (info != null) {
                if (markUnpaired == true) {
                    PairState.MARK_UNPAIRED
                } else {
                    if (info.toString() != device.info.toString()) {
                        ConfigUtil.Device.addPairedDevice(device.info)
                    }
                    PairState.PAIRED
                }
            } else {
                PairState.NOT_PAIRED
            }
            onStateChanged(state)
        }
    }

    enum class PairState {
        UNKNOWN, NOT_PAIRED, PAIRED, MARK_UNPAIRED, REQUESTED,
    }

    val isReady: Boolean get() = state != PairState.UNKNOWN

    var state: PairState = PairState.UNKNOWN
        private set

    fun handle(data: Map<String, Any?>) {
        when (data["message"].toString()) {
            "accepted" -> {
                ConfigUtil.Device.addPairedDevice(device.info)
                state = PairState.PAIRED
                onStateChanged(state)
            }

            "rejected" -> {
                state = PairState.NOT_PAIRED
                onStateChanged(state)
            }

            "unpair" -> {
                ConfigUtil.Device.removePairedDevice(device.info)
                state = PairState.NOT_PAIRED
                onStateChanged(state)
            }
        }
    }
}