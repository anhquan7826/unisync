package com.anhquan.unisync.features

import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.plugins.UnisyncPlugin
import com.anhquan.unisync.utils.infoLog

abstract class UnisyncFeature {
    data class FeatureNotifierMessage(val device: DeviceInfo, val deviceMessage: DeviceMessage)

    protected val pluginHandlers = mutableMapOf<String, UnisyncPlugin.UnisyncPluginHandler>()

    var isAvailable: Boolean = false
        protected set

    fun addHandler(plugin: String, handler: UnisyncPlugin.UnisyncPluginHandler) {
        pluginHandlers[plugin] = handler
        checkAvailability()
        if (isAvailable) {
            infoLog("${this::class.simpleName}: feature is ready.")
            onFeatureReady()
            handle()
        }
    }

    private fun handle() {
        handleMethodChannelCall()
        handlePluginData()
    }

    protected abstract fun onFeatureReady()

    protected abstract fun checkAvailability()

    protected abstract fun handlePluginData()

    protected abstract fun handleMethodChannelCall()

    protected abstract fun handleDeviceMessage()

    companion object {
        const val FEATURE_CONNECTION = "connection"
        const val FEATURE_PAIRING = "pairing"
    }
}