package com.anhquan.unisync.models

import com.anhquan.unisync.constants.MessageType

data class DeviceResponse(
    val request: Int,
    val result: Int,
    val data: Map<String, Any>
) {
    val type = MessageType.response

    companion object {
        const val RESPONSE_OK = 0
        const val RESPONSE_NOK = 1
    }
}
