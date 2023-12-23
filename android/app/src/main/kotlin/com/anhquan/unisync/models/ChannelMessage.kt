package com.anhquan.unisync.models

data class ChannelMessage(
    val channel: String,
    val method: String,
    val args: Map<String, Any?> = mapOf()
)
