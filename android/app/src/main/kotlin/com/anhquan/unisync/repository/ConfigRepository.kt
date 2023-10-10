package com.anhquan.unisync.repository

import com.anhquan.unisync.models.DeviceInfo

interface ConfigRepository {
    val deviceInfo: DeviceInfo

    val packageName: String
}