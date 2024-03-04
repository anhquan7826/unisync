package com.anhquan.unisync.core.device.dependencies

import com.anhquan.unisync.core.device.Device
import com.anhquan.unisync.core.providers.DeviceProvider
import com.anhquan.unisync.database.entity.PairedDeviceEntity
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.Database
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.listen

class PairingHandler(private val device: Device) {
    interface PairOperation {
        fun requestPair()

        fun unpair()
    }
    
    val operation = object : PairOperation {
        override fun requestPair() {
            if (state == PairState.NOT_PAIRED) {
                device.sendMessage(
                    DeviceMessage(
                        type = DeviceMessage.Type.PAIR,
                        body = mapOf(
                            "message" to "requested"
                        )
                    )
                )
                state = PairState.REQUESTED
                notifyDevice()
            }
        }

        override fun unpair() {
            if (state == PairState.PAIRED) {
                Database.pairedDevice.remove(device.info.id)
                device.sendMessage(
                    DeviceMessage(
                        type = DeviceMessage.Type.PAIR,
                        body = mapOf(
                            "message" to "unpair"
                        )
                    )
                )
                state = PairState.NOT_PAIRED
                notifyDevice()
            }
        }
    }

    init {
        Database.pairedDevice.exist(device.info.id).listen {
            state = if (it == 1) PairState.PAIRED else PairState.NOT_PAIRED
            debugLog("${this::class.simpleName}@${device.info.name}: $state")
            notifyDevice()
        }
    }

    enum class PairState {
        NOT_PAIRED,
        PAIRED,
        REQUESTED,
    }

    var state: PairState = PairState.NOT_PAIRED
        private set

    fun onMessageReceived(message: DeviceMessage) {
        if (message.type == DeviceMessage.Type.PAIR && message.body.containsKey("message")) {
            when (message.body["message"].toString()) {
                "accepted" -> {
                    Database.pairedDevice.add(
                        PairedDeviceEntity(
                            id = device.info.id,
                            name = device.info.name,
                            type = device.info.deviceType
                        )
                    ).listen {}
                    state = PairState.PAIRED
                    notifyDevice()
                }

                "rejected" -> {
                    state = PairState.NOT_PAIRED
                    notifyDevice()
                }

                "unpair" -> {
                    Database.pairedDevice.remove(device.info.id).listen {}
                    state = PairState.NOT_PAIRED
                    notifyDevice()
                }
            }
        }
    }

    private fun notifyDevice() {
        DeviceProvider.deviceNotifier.onNext(
            DeviceProvider.DeviceNotification(device.info, pairState = state)
        )
    }
}