package com.anhquan.unisync.core.interfaces

import com.anhquan.unisync.models.DeviceMessage

interface IDeviceConnection {
    fun send(message: DeviceMessage)
}