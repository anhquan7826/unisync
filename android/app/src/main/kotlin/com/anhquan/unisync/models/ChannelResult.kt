package com.anhquan.unisync.models

data class ChannelResult(
    val method: String,
    val resultCode: Int,
    val result: Any? = null,
    val error: String? = null,
) {
    companion object {
        const val SUCCESS = 0
        const val FAILED = -1
    }
}
