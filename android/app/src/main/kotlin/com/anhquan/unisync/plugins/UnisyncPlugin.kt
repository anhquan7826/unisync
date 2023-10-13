package com.anhquan.unisync.plugins

import android.content.Context

abstract class UnisyncPlugin {
    companion object {
        const val MDNS_PLUGIN = "mdns"
        const val SOCKET_PLUGIN = "socket"
    }

    interface UnisyncPluginHandler

    interface UnisyncPluginConnection {
        fun onPluginStarted(handler: UnisyncPluginHandler)

        fun onPluginError(error: Exception)

        fun onPluginStopped()
    }

    abstract val pluginConnection: UnisyncPluginConnection

    abstract val pluginHandler: UnisyncPluginHandler

    abstract fun start(context: Context)

    abstract fun stop()
}