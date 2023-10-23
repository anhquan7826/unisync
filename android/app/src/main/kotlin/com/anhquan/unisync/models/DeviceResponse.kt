package com.anhquan.unisync.models

data class DeviceResponse(
    val request: Int,
    val result: Int,
    val data: Map<String, Any>
) {
    companion object {
        const val RESPONSE_OK = 0
        const val RESPONSE_NOK = 1
    }
}
