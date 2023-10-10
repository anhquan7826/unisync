package com.anhquan.unisync.plugins

import com.anhquan.unisync.constants.NetworkPorts
import com.anhquan.unisync.extensions.text
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.errorLog
import com.anhquan.unisync.utils.infoLog
import java.net.InetAddress
import javax.jmdns.JmDNS
import javax.jmdns.ServiceEvent
import javax.jmdns.ServiceInfo
import javax.jmdns.ServiceListener

object MdnsPlugin {
    private const val serviceType = "_http._tcp.local."

    private lateinit var ip: String
    private lateinit var name: String

    private lateinit var jmdns: JmDNS
    private lateinit var serviceInfo: ServiceInfo
    private lateinit var serviceListener: ServiceListener

    fun addServiceInfo(ip: String, name: String, info: String) {
        this.ip = ip
        this.name = name
        serviceInfo = ServiceInfo.create(
            serviceType,
            name,
            NetworkPorts.discoveryPort,
            info
        )
    }

    fun addServiceListener(
        onAddService: (info: String) -> Unit,
        onRemoveService: (info: String) -> Unit
    ) {
        serviceListener = object : ServiceListener {
            override fun serviceAdded(event: ServiceEvent?) {}

            override fun serviceRemoved(event: ServiceEvent?) {
                if (event != null) {
                    if (event.info.name == serviceInfo.name && event.info.text != serviceInfo.text) {
                        onRemoveService.invoke(event.info.text)
                    }
                }
            }

            override fun serviceResolved(event: ServiceEvent?) {
                if (event != null) {
                    if (event.info.name == serviceInfo.name && event.info.text != serviceInfo.text) {
                        onAddService.invoke(event.info.text)
                    }
                }
            }
        }
    }

    fun getDiscoveredServices(): List<String> {
        val result = mutableListOf<String>()
        for (service in jmdns.list(serviceType)) {
            result.add(service.text)
        }
        return result
    }

    fun start() {
        try {
            jmdns = JmDNS.create(InetAddress.getByName(ip), name)
            jmdns.registerService(serviceInfo)
            debugLog("${this::class.simpleName}: added service info: '$serviceInfo'.")
            if (this::serviceListener.isInitialized) {
                jmdns.addServiceListener(
                    serviceType,
                    serviceListener
                )
                debugLog("${this::class.simpleName}: added service listener.")
            }
            infoLog("${this::class.simpleName}: service started.")
        } catch (e: Exception) {
            errorLog("${this::class.simpleName}: cannot create JmDNS instance!\n${e.message}")
            throw e
        }
    }

    fun stop() {
        try {
            jmdns.unregisterAllServices()
            if (this::serviceListener.isInitialized) jmdns.removeServiceListener(
                serviceType,
                serviceListener
            )
            jmdns.close()
            infoLog("${this::class.simpleName}: service stopped.")
        } catch (e: Exception) {
            errorLog("${this::class.simpleName}: cannot stop service: ${e.message}")
            throw e
        }
    }
}