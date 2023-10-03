package com.anhquan.unisync.plugins

import com.anhquan.unisync.models.ClientInfo
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.errorLog
import com.google.gson.Gson
import java.io.IOException
import javax.jmdns.JmDNS
import javax.jmdns.ServiceInfo
import javax.jmdns.ServiceListener

class mDNSPlugin {
    private val serviceType = "_http._tcp.local."

    private lateinit var jmdns: JmDNS
    private lateinit var serviceInfo: ServiceInfo
    private lateinit var serviceListener: ServiceListener

    private lateinit var clientInfo: ClientInfo
    var isRegistered = false
        private set

    fun create() {
        try {
            jmdns = JmDNS.create()
        } catch (e: IOException) {
            errorLog("mDNS Plugin cannot create JmDNS client!")
            errorLog("Error message: ${e.message}")
        }
    }

    // TODO: Add more client info
    fun register(clientInfo: ClientInfo) {
        this.clientInfo = clientInfo
        serviceInfo =
            ServiceInfo.create(serviceType, "unisync", 2002, Gson().toJson(clientInfo))
        try {
            jmdns.registerService(serviceInfo)
            isRegistered = true
            debugLog("mDNS Plugin registered!")
            debugLog(serviceInfo.toString())
        } catch (e: IOException) {
            isRegistered = false
            errorLog("mDNS Plugin cannot register!")
            errorLog("Error message: ${e.message}")
        }
    }

    fun unregister() {
        jmdns.unregisterAllServices()
        isRegistered = false
        debugLog("mDNS Plugin unregistered!")
    }

    fun addListener(listener: ServiceListener) {
        serviceListener = listener
        jmdns.addServiceListener(serviceType, serviceListener)
        debugLog("mDNS Plugin listener added!")
    }

    fun removeListener() {
        jmdns.removeServiceListener(serviceType, serviceListener)
        debugLog("mDNS Plugin listener removed!")
    }

    fun getServices(): List<ServiceInfo> {
        return jmdns.list(serviceType).toList()
    }
}