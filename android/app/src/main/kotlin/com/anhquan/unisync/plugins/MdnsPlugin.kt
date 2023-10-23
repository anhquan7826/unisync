package com.anhquan.unisync.plugins

import android.content.Context
import android.net.nsd.NsdManager
import android.net.nsd.NsdManager.DiscoveryListener
import android.net.nsd.NsdManager.ResolveListener
import android.net.nsd.NsdManager.ServiceInfoCallback
import android.net.nsd.NsdServiceInfo
import android.os.Build
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.errorLog
import com.anhquan.unisync.utils.infoLog
import com.anhquan.unisync.utils.runSingle
import io.reactivex.rxjava3.subjects.ReplaySubject

class MdnsPlugin(override val pluginConnection: UnisyncPluginConnection) : UnisyncPlugin() {
    inner class MdnsPluginHandler : UnisyncPluginHandler {
        val onServiceIpFound = ReplaySubject.create<String>()
    }

    override val pluginHandler: MdnsPluginHandler = MdnsPluginHandler()

    private val serviceType = "_unisync._tcp"
    private lateinit var nsdManager: NsdManager
    private lateinit var discoveryListener: DiscoveryListener

    override fun start(context: Context) {
        infoLog("${this::class.simpleName}: starting Mdns plugin.")
        runSingle {
            try {
                nsdManager = context.getSystemService(NsdManager::class.java)
                configureServiceDiscovery()
                pluginConnection.onPluginStarted(pluginHandler)
            } catch (e: Exception) {
                infoLog("${this::class.simpleName}: cannot start Mdns plugin: ${e.message}")
                nsdManager.stopServiceDiscovery(discoveryListener)
                pluginConnection.onPluginError(e)
            }
        }
    }

    override fun stop() {
        runSingle {
            try {
                pluginConnection.onPluginStopped()
            } catch (e: Exception) {
                pluginConnection.onPluginError(e)
            }
        }
    }

    private fun configureServiceDiscovery() {
        discoveryListener = object : DiscoveryListener {
            override fun onStartDiscoveryFailed(p0: String?, p1: Int) {
                errorLog("${this@MdnsPlugin::class.simpleName}: failed to start discovery: Code $p1: error: $p0")
            }

            override fun onStopDiscoveryFailed(p0: String?, p1: Int) {
                errorLog("${this@MdnsPlugin::class.simpleName}: failed to stop discovery: Code $p1: error: $p0")
            }

            override fun onDiscoveryStarted(p0: String?) {
                infoLog("${this@MdnsPlugin::class.simpleName}: discovery started.")
            }

            override fun onDiscoveryStopped(p0: String?) {
                infoLog("${this@MdnsPlugin::class.simpleName}: discovery stopped.")
            }

            override fun onServiceFound(serviceInfo: NsdServiceInfo?) {
                debugLog(serviceInfo)
                if (serviceInfo != null) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                        nsdManager.registerServiceInfoCallback(
                            serviceInfo,
                            {},
                            object : ServiceInfoCallback {
                                override fun onServiceInfoCallbackRegistrationFailed(p0: Int) {
                                    nsdManager.unregisterServiceInfoCallback(this)
                                }

                                override fun onServiceUpdated(p0: NsdServiceInfo) {
                                    p0.hostAddresses.mapNotNull { it.hostAddress }
                                        .firstOrNull { isIPv4(it) }?.let {
                                            onAddressFound(it)
                                        }
                                    nsdManager.unregisterServiceInfoCallback(this)
                                }

                                override fun onServiceLost() {
                                    nsdManager.unregisterServiceInfoCallback(this)
                                }

                                override fun onServiceInfoCallbackUnregistered() {
                                    nsdManager.unregisterServiceInfoCallback(this)
                                }
                            }
                        )
                    } else {
                        nsdManager.resolveService(
                            serviceInfo,
                            object : ResolveListener {
                                override fun onResolveFailed(p0: NsdServiceInfo?, p1: Int) {}

                                override fun onServiceResolved(p0: NsdServiceInfo?) {
                                    p0?.host?.hostAddress?.let {
                                        if (isIPv4(it)) {
                                            onAddressFound(it)
                                        }
                                    }
                                }
                            }
                        )
                    }
                }
            }

            override fun onServiceLost(p0: NsdServiceInfo?) {}
        }
        nsdManager.discoverServices(serviceType, NsdManager.PROTOCOL_DNS_SD, discoveryListener)
    }

    private fun onAddressFound(address: String) {
        infoLog("${this::class.simpleName}: Found a service on address: $address.")
        pluginHandler.onServiceIpFound.onNext(address)
    }

    private fun isIPv4(address: String): Boolean {
        val ipv4Pattern = Regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$")
        return ipv4Pattern.matches(address)
    }
}