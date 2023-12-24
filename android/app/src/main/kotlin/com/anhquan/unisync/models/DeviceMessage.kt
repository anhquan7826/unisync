package com.anhquan.unisync.models

data class DeviceMessage(
    val fromDeviceId: String,
    val plugin: String,
    val function: String,
    val extra: Map<String, Any?> = mapOf()
) {
    object Pairing {
        const val REQUEST_PAIR = "request_pair"
        const val PAIR_ACCEPTED = "pair_accepted"
        const val PAIR_REJECTED = "pair_rejected"
        const val UNPAIR = "unpair"
    }
}
