package com.anhquan.unisync.models

import com.anhquan.unisync.constants.MessageType

data class DeviceRequest(
    val request: Int,
    val extras: Map<String, Any> = mapOf()
) {
    val type = MessageType.request

    companion object {
        const val REQUEST_PAIR = 0
    }
}