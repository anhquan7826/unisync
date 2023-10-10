package com.anhquan.unisync.models

data class DeviceInfo(
    val id: String,
    val name: String,
    val ip: String = "",
    val publicKey: String = "",
    val deviceType: String,
)