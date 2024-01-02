package com.anhquan.unisync.core

import com.anhquan.unisync.core.interfaces.IDeviceConnection
import com.anhquan.unisync.core.interfaces.IMessageListener
import com.anhquan.unisync.database.UnisyncDatabase
import com.anhquan.unisync.database.entity.PairedDeviceEntity
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.NotificationUtil
import com.anhquan.unisync.utils.listen

class PairingHandler(device: Device) : IMessageListener {
    interface PairingOperation {
        fun requestPair()

        fun acceptPair()

        fun rejectPair()

        fun unpair()
    }

    private val database: UnisyncDatabase = ConfigUtil.database
    private val connection: IDeviceConnection = device.connection
    private val info: DeviceInfo = device.deviceInfo

    val operation = object : PairingOperation {
        override fun requestPair() {
            if (state == PairState.NOT_PAIRED) {
                connection.send(
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

        override fun acceptPair() {
            if (state == PairState.REQUESTED_BY_PEER) {
                connection.send(
                    DeviceMessage(
                        type = DeviceMessage.Type.PAIR,
                        body = mapOf(
                            "message" to "accepted"
                        )
                    )
                )
                state = PairState.PAIRED
            }
        }

        override fun rejectPair() {
            if (state == PairState.REQUESTED_BY_PEER) {
                connection.send(
                    DeviceMessage(
                        type = DeviceMessage.Type.PAIR,
                        body = mapOf(
                            "message" to "rejected"
                        )
                    )
                )
                state = PairState.NOT_PAIRED
            }
        }

        override fun unpair() {
            database.pairedDeviceDao().remove(info.id)
            connection.send(
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

    init {
        database.pairedDeviceDao().exist(device.deviceInfo.id).listen {
            state = if (it == 1) PairState.PAIRED else PairState.NOT_PAIRED
        }
    }

    enum class PairState {
        NOT_PAIRED,
        PAIRED,
        REQUESTED,
        REQUESTED_BY_PEER
    }

    var state: PairState = PairState.NOT_PAIRED
        private set

    override fun onMessageReceived(message: DeviceMessage) {
        if (message.body.containsKey("message")) {
            when (message.body["message"].toString()) {
                "requested" -> {
                    state = PairState.REQUESTED_BY_PEER
                    NotificationUtil
                }

                "accepted" -> {
                    database.pairedDeviceDao().add(
                        PairedDeviceEntity(
                            id = info.id,
                            name = info.name,
                            type = info.deviceType
                        )
                    )
                    state = PairState.PAIRED
                }

                "rejected" -> {
                    state = PairState.NOT_PAIRED
                }

                "unpair" -> {
                    database.pairedDeviceDao().remove(info.id)
                    state = PairState.NOT_PAIRED
                }
            }
        }
    }
}