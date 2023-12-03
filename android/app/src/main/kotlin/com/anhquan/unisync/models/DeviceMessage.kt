package com.anhquan.unisync.models

data class DeviceMessage(
    val messageType: Int,
    val information: String,
    val data: Map<String, Any?> = mapOf()
) {
    companion object {
        const val REQUEST = 1
        const val RESPONSE = 2
        const val STATUS = 0
    }

    object MessageInformation {
        const val DEVICE_PAIR_REQUEST = "device_pair_request"
        const val DEVICE_PAIR_RESULT = "device_pair_result"
        const val SHARED_SECRET = "shared_secret"
    }
}
