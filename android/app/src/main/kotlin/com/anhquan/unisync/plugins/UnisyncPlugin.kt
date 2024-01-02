package com.anhquan.unisync.plugins

import com.anhquan.unisync.core.interfaces.IDeviceConnection
import com.anhquan.unisync.core.interfaces.IMessageListener

abstract class UnisyncPlugin(private val connection: IDeviceConnection) : IMessageListener {
}