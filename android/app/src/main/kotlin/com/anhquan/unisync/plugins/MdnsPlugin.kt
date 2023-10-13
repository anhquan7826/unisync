package com.anhquan.unisync.plugins

import android.content.Context
import android.net.ConnectivityManager
import android.net.wifi.WifiManager
import android.net.wifi.WifiManager.MulticastLock
import com.anhquan.unisync.constants.NetworkPorts
import com.anhquan.unisync.extensions.text
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.infoLog
import com.anhquan.unisync.utils.runSingle
import com.anhquan.unisync.utils.toJson
import java.net.InetAddress
import javax.jmdns.JmDNS
import javax.jmdns.ServiceEvent
import javax.jmdns.ServiceInfo
import javax.jmdns.ServiceListener

class MdnsPlugin(
    override val pluginConnection: UnisyncPluginConnection = object : UnisyncPluginConnection {
        override fun onPluginStarted(handler: UnisyncPluginHandler) {
            infoLog("${this::class.simpleName}: mDNS plugin started.")
        }

        override fun onPluginError(error: Exception) {
            infoLog("${this::class.simpleName}: mDNS plugin error:\n${error.message}")
        }

        override fun onPluginStopped() {
            infoLog("${this::class.simpleName}: mDNS plugin stopped.")
        }
    },
) : UnisyncPlugin() {
    inner class MdnsPluginHandler : UnisyncPluginHandler {
        var onServiceAdded: ((ServiceInfo) -> Unit)? = null
        var onServiceRemoved: ((ServiceInfo) -> Unit)? = null

        fun getDiscoveredServices(onResult: (List<ServiceInfo>) -> Unit) {
            runSingle {
                jmdns.list(serviceType).filter {
                    it.text != toJson(deviceInfo)
                }.let { list ->
                    onResult.invoke(list)
                }
            }
        }
    }

    override val pluginHandler: MdnsPluginHandler = MdnsPluginHandler()

    private val serviceType = "_http._tcp.local."

    private lateinit var deviceInfo: DeviceInfo
    private lateinit var serviceName: String
    private lateinit var ip: String

    private lateinit var jmdns: JmDNS

    private lateinit var connectivityManager: ConnectivityManager
    private lateinit var wifiManager: WifiManager

    private lateinit var multicastLock: MulticastLock

    override fun start(context: Context) {
        infoLog("${this::class.simpleName}: starting Mdns plugin.")
        runSingle {
            try {
                connectivityManager = context.getSystemService(ConnectivityManager::class.java)
                wifiManager = context.getSystemService(WifiManager::class.java)
                serviceName = context.packageName
                deviceInfo = ConfigUtil.getDeviceInfo(context)

                acquireMulticastLock()
                configureJmDNS()
                pluginConnection.onPluginStarted(pluginHandler)
            } catch (e: Exception) {
                releaseMulticastLock()
                pluginConnection.onPluginError(e)
            }
        }
    }

    override fun stop() {
        runSingle {
            try {
                releaseMulticastLock()
                jmdns.close()
                pluginConnection.onPluginStopped()
            } catch (e: Exception) {
                pluginConnection.onPluginError(e)
            }
        }
    }

    private fun acquireMulticastLock() {
        val ipv4Pattern = Regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$")
        val linkAddress = connectivityManager
            .getLinkProperties(connectivityManager.activeNetwork)
            ?.linkAddresses?.firstOrNull {
                it.address.hostAddress?.let { it1 -> ipv4Pattern.matches(it1) } == true
            }
        ip = linkAddress
            ?.address
            ?.hostAddress ?: "127.0.0.1"
        debugLog("${this::class.simpleName}: creating multicast lock.")
        multicastLock = wifiManager.createMulticastLock(serviceName)
        multicastLock.apply {
            setReferenceCounted(true)
            acquire()
            debugLog("${this::class.simpleName}: acquired multicast lock at ip address: $ip.")
        }
    }

    private fun releaseMulticastLock() {
        multicastLock.release()
    }

    private fun configureJmDNS() {
        debugLog("${this::class.simpleName}: creating JmDNS instance.")
        jmdns = JmDNS.create(InetAddress.getByName(ip), serviceName)
        debugLog("${this::class.simpleName}: JmDNS instance created.")
        jmdns.registerService(
            ServiceInfo.create(
                serviceType,
                serviceName,
                NetworkPorts.discoveryPort,
                toJson(deviceInfo)
            )
        )
        debugLog("${this::class.simpleName}: registered JmDNS service.")
        jmdns.addServiceListener(serviceType, object : ServiceListener {
            override fun serviceAdded(event: ServiceEvent?) {}

            override fun serviceRemoved(event: ServiceEvent?) {
                if (event != null) {
                    if (
                        event.info.name == serviceName &&
                        event.info.text != toJson(deviceInfo)
                    ) {
                        pluginHandler.onServiceAdded?.invoke(event.info)
                    }
                }
            }

            override fun serviceResolved(event: ServiceEvent?) {
                if (event != null) {
                    if (
                        event.info.name == serviceName &&
                        event.info.text != toJson(deviceInfo)
                    ) {
                        pluginHandler.onServiceRemoved?.invoke(event.info)
                    }
                }
            }
        })
        debugLog("${this::class.simpleName}: added JmDNS service listener.")
    }
}