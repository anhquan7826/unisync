package com.anhquan.unisync.models

data class DeviceRequest(
    val request: Int,
    val extras: Map<String, Any>
) {
    companion object {
        const val REQUEST_PAIR = 0
    }
}
