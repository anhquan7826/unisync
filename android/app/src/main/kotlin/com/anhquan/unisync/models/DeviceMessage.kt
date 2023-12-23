package com.anhquan.unisync.models

data class DeviceMessage(
    val deviceId: String,
    val plugin: String,
    val function: String,
    val extra: Map<String, Any?> = mapOf()
)
