package com.anhquan.unisync.features

import com.anhquan.unisync.plugins.UnisyncPlugin
import com.anhquan.unisync.utils.infoLog

abstract class UnisyncFeature {
    protected val handlers = mutableMapOf<String, UnisyncPlugin.UnisyncPluginHandler>()

    var isAvailable: Boolean = false
        protected set

    fun addHandler(plugin: String, handler: UnisyncPlugin.UnisyncPluginHandler) {
        handlers[plugin] = handler
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

    protected open fun onFeatureReady() {}

    protected abstract fun checkAvailability()

    protected abstract fun handlePluginData()

    protected abstract fun handleMethodChannelCall()

    companion object {
        const val FEATURE_PAIRING = "pairing"
    }
}