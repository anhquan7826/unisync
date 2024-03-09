package com.anhquan.unisync.core

import com.anhquan.unisync.database.entity.PairedDeviceEntity
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.Database
import com.anhquan.unisync.utils.listen

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
                Database.pairedDevice.remove(device.info.id)
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
        Database.pairedDevice.exist(device.info.id).listen {
            state = if (it == 1) PairState.PAIRED else PairState.NOT_PAIRED
            onStateChanged(state)
        }
    }

    enum class PairState {
        UNKNOWN, NOT_PAIRED, PAIRED, REQUESTED,
    }

    val isReady: Boolean get() = state != PairState.UNKNOWN

    var state: PairState = PairState.UNKNOWN
        private set

    fun handle(data: Map<String, Any?>) {
        when (data["message"].toString()) {
            "accepted" -> {
                Database.pairedDevice.add(
                    PairedDeviceEntity(
                        id = device.info.id,
                        name = device.info.name,
                        type = device.info.deviceType
                    )
                ).listen {}
                state = PairState.PAIRED
                onStateChanged(state)
            }

            "rejected" -> {
                state = PairState.NOT_PAIRED
                onStateChanged(state)
            }

            "unpair" -> {
                Database.pairedDevice.remove(device.info.id).listen {}
                state = PairState.NOT_PAIRED
                onStateChanged(state)
            }
        }
    }

//    private fun notifyDevice() {
//        DeviceProvider.deviceNotifier.onNext(
//            DeviceProvider.DeviceNotification(device.info, pairState = state)
//        )
//    }
}