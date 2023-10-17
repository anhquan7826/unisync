package com.anhquan.unisync.plugins

import android.content.Context
import com.anhquan.unisync.utils.infoLog

abstract class UnisyncPlugin {
    companion object {
        const val PLUGIN_MDNS = "mdns"
        const val PLUGIN_SOCKET = "socket"
    }

    object Builder {
        @Suppress("UNCHECKED_CAST")
        fun <T : UnisyncPlugin> buildPlugin(
            plugin: Class<T>,
            onStart: ((UnisyncPluginHandler) -> Unit)? = null,
            onError: ((Exception) -> Unit)? = null,
            onStop: (() -> Unit)? = null
        ): T {
            val connection = object : UnisyncPluginConnection {
                override fun onPluginStarted(handler: UnisyncPluginHandler) {
                    super.onPluginStarted(handler)
                    onStart?.invoke(handler)
                }

                override fun onPluginStopped() {
                    super.onPluginStopped()
                    onStop?.invoke()
                }

                override fun onPluginError(error: Exception) {
                    super.onPluginError(error)
                    onError?.invoke(error)
                }
            }
            return when (plugin) {
                MdnsPlugin::class.java -> MdnsPlugin(connection) as T
                SocketPlugin::class.java -> SocketPlugin(connection) as T
                else -> {
                    throw Exception("Invalid plugin type!")
                }
            }
        }
    }

    interface UnisyncPluginHandler

    interface UnisyncPluginConnection {
        fun onPluginStarted(handler: UnisyncPluginHandler) {
            infoLog("plugin started.")
        }

        fun onPluginError(error: Exception) {
            infoLog("plugin error:\n${error.message}")
        }

        fun onPluginStopped() {
            infoLog("plugin stopped.")
        }
    }

    abstract val pluginConnection: UnisyncPluginConnection

    abstract val pluginHandler: UnisyncPluginHandler

    abstract fun start(context: Context)

    abstract fun stop()
}