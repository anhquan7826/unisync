package com.anhquan.unisync.repository

import com.anhquan.unisync.models.DeviceInfo

interface PairingRepository {
    fun startService()

    fun stopService()

    fun getDiscoveredDevices(): List<DeviceInfo>

    fun addListener(
        onClientAdded: (DeviceInfo) -> Unit,
        onClientRemoved: (DeviceInfo) -> Unit,
    )
    fun requestPair(client: DeviceInfo)
}