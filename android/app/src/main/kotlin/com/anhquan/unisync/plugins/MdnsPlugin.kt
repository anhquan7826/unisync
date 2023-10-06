package com.anhquan.unisync.plugins

import com.anhquan.unisync.constants.NetworkPorts
import com.anhquan.unisync.extensions.text
import com.anhquan.unisync.utils.errorLog
import com.anhquan.unisync.utils.infoLog
import com.anhquan.unisync.utils.runSingle
import javax.jmdns.JmDNS
import javax.jmdns.ServiceEvent
import javax.jmdns.ServiceInfo
import javax.jmdns.ServiceListener

object MdnsPlugin {
    private const val serviceType = "_http._tcp.local."
    private const val serviceName = "com.anhquan.unisync"

    private lateinit var jmdns: JmDNS
    private lateinit var serviceInfo: ServiceInfo
    private lateinit var serviceListener: ServiceListener

    fun addServiceInfo(name: String, info: String) {
        serviceInfo = ServiceInfo.create(
            serviceType,
            name,
            NetworkPorts.discoveryPort,
            info
        )
    }

    fun addServiceDiscoveryListener(
        onAddService: (info: String) -> Unit,
        onRemoveService: (info: String) -> Unit
    ) {
        serviceListener = object : ServiceListener {
            override fun serviceAdded(event: ServiceEvent?) {}

            override fun serviceRemoved(event: ServiceEvent?) {
                if (event != null) {
                    if (event.info.name == serviceInfo.name) {
                        onRemoveService.invoke(event.info.text)
                    }
                }
            }

            override fun serviceResolved(event: ServiceEvent?) {
                if (event != null) {
                    if (event.info.name == serviceInfo.name) {
                        onAddService.invoke(event.info.text)
                    }
                }
            }
        }
    }

    fun start() {
        runSingle(
            callback = {
                if (!this::jmdns.isInitialized) jmdns = JmDNS.create()
                jmdns.registerService(serviceInfo)
                jmdns.addServiceListener(serviceType, serviceListener)
                infoLog("MdnsPlugin: service started.")
            },
            onError = {
                errorLog("mDNSPlugin: cannot create JmDNS instance!\n${it.message}")
            }
        )
    }

    fun stop() {
        runSingle {
            jmdns.unregisterAllServices()
            jmdns.removeServiceListener(serviceType, serviceListener)
            infoLog("MdnsPlugin: service stopped.")
        }
    }
}