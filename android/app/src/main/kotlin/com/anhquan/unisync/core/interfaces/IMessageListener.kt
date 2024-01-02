package com.anhquan.unisync.core.interfaces

import com.anhquan.unisync.models.DeviceMessage

interface IMessageListener {
    fun onMessageReceived(message: DeviceMessage)
}