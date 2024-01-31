package com.anhquan.unisync.core.device.dependencies

import com.anhquan.unisync.core.device.Device
import com.anhquan.unisync.database.UnisyncDatabase
import com.anhquan.unisync.database.entity.PairedDeviceEntity
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.NotificationUtil
import com.anhquan.unisync.utils.listen

class PairingHandler(private val device: Device) :
    NotificationUtil.NotificationHandler(NotificationUtil.CHANNEL_ID_PAIR) {
    interface PairingOperation {
        fun requestPair()

        fun unpair()
    }

    private val database: UnisyncDatabase = ConfigUtil.database

    val operation = object : PairingOperation {
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
            }
        }

        override fun unpair() {
            if (state == PairState.PAIRED) {
                database.pairedDeviceDao().remove(device.info.id)
                device.sendMessage(
                    DeviceMessage(
                        type = DeviceMessage.Type.PAIR,
                        body = mapOf(
                            "message" to "unpair"
                        )
                    )
                )
                state = PairState.NOT_PAIRED
            }
        }

    }

    init {
        database.pairedDeviceDao().exist(device.info.id).listen {
            state = if (it == 1) PairState.PAIRED else PairState.NOT_PAIRED
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
                    database.pairedDeviceDao().add(
                        PairedDeviceEntity(
                            id = device.info.id,
                            name = device.info.name,
                            type = device.info.deviceType
                        )
                    )
                    state = PairState.PAIRED
                }

                "rejected" -> {
                    state = PairState.NOT_PAIRED
                }

                "unpair" -> {
                    database.pairedDeviceDao().remove(device.info.id)
                    state = PairState.NOT_PAIRED
                }
            }
        }
    }
}