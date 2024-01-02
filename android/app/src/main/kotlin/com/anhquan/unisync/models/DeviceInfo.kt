package com.anhquan.unisync.models

data class DeviceInfo(
    val id: String,
    val name: String,
    val ip: String = "",
    val publicKey: String = "",
    val deviceType: String,
) {
    override fun hashCode(): Int {
        return id.hashCode()
    }

    override fun equals(other: Any?): Boolean {
        if (other !is DeviceInfo) return false
        return id == other.id;
    }
}