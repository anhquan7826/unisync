package com.anhquan.unisync.core.discovery

import android.annotation.SuppressLint
import android.content.Context
import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.os.Build
import com.anhquan.unisync.constants.NetworkPorts
import com.anhquan.unisync.core.providers.DeviceProvider
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.errorLog
import com.anhquan.unisync.utils.extensions.isIPv4
import com.anhquan.unisync.utils.gson
import com.anhquan.unisync.utils.infoLog
import com.anhquan.unisync.utils.runSingle
import com.anhquan.unisync.utils.toJson
import java.security.cert.X509Certificate
import javax.net.ssl.SSLContext
import javax.net.ssl.SSLSocket
import javax.net.ssl.SSLSocketFactory
import javax.net.ssl.X509TrustManager

class DeviceDiscovery(private val context: Context) {
    private val trustAllManager = @SuppressLint("CustomX509TrustManager")
    object : X509TrustManager {
        @SuppressLint("TrustAllX509TrustManager")
        override fun checkClientTrusted(chain: Array<out X509Certificate>?, authType: String?) {
        }

        @SuppressLint("TrustAllX509TrustManager")
        override fun checkServerTrusted(chain: Array<out X509Certificate>?, authType: String?) {
        }

        override fun getAcceptedIssuers(): Array<X509Certificate> {
            return arrayOf()
        }
    }

    private val sslSocketFactory: SSLSocketFactory = SSLContext.getInstance("TLS").let {
        it.init(null, arrayOf(trustAllManager), null)
        it.socketFactory
    }

    private val serviceType = "_unisync._tcp"
    private lateinit var nsdManager: NsdManager
    private lateinit var discoveryListener: NsdManager.DiscoveryListener

    fun start() {
        nsdManager = context.getSystemService(NsdManager::class.java)
        configureServiceDiscovery()
//        connectToAddress("10.0.2.2")
    }

    fun stop() {
        nsdManager.stopServiceDiscovery(discoveryListener)
    }

    private fun configureServiceDiscovery() {
        discoveryListener = object : NsdManager.DiscoveryListener {
            override fun onStartDiscoveryFailed(p0: String?, p1: Int) {
                errorLog("${this@DeviceDiscovery::class.simpleName}: failed to start discovery: Code $p1: error: $p0")
            }

            override fun onStopDiscoveryFailed(p0: String?, p1: Int) {
                errorLog("${this@DeviceDiscovery::class.simpleName}: failed to stop discovery: Code $p1: error: $p0")
            }

            override fun onDiscoveryStarted(p0: String?) {
                infoLog("${this@DeviceDiscovery::class.simpleName}: discovery started.")
            }

            override fun onDiscoveryStopped(p0: String?) {
                infoLog("${this@DeviceDiscovery::class.simpleName}: discovery stopped.")
            }

            override fun onServiceFound(serviceInfo: NsdServiceInfo?) {
                debugLog(serviceInfo)
                if (serviceInfo != null) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                        nsdManager.registerServiceInfoCallback(
                            serviceInfo,
                            {
                                it.run()
                            },
                            object : NsdManager.ServiceInfoCallback {
                                override fun onServiceInfoCallbackRegistrationFailed(p0: Int) {
                                }

                                override fun onServiceUpdated(p0: NsdServiceInfo) {
                                    p0.hostAddresses.mapNotNull { it.hostAddress }
                                        .firstOrNull { it.isIPv4() }?.let {
                                            connectToAddress(it)
                                        }
                                    nsdManager.unregisterServiceInfoCallback(this)
                                }

                                override fun onServiceLost() {}

                                override fun onServiceInfoCallbackUnregistered() {}
                            }
                        )
                    } else {
                        nsdManager.resolveService(
                            serviceInfo,
                            object : NsdManager.ResolveListener {
                                override fun onResolveFailed(p0: NsdServiceInfo?, p1: Int) {}

                                override fun onServiceResolved(p0: NsdServiceInfo?) {
                                    p0?.host?.hostAddress?.let {
                                        if (it.isIPv4()) {
                                            connectToAddress(it)
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

    fun connectToAddress(address: String) {
        runSingle {
            infoLog("${this::class.simpleName}: Found a service on address: $address.")
            try {
                val socket = sslSocketFactory.createSocket(
                    address,
                    NetworkPorts.serverPort
                ) as SSLSocket
                socket.keepAlive = true
                onNewSocket(socket)
            } catch (e: Exception) {
                errorLog("${this::class.simpleName}: Cannot create a socket connection to $address.")
                e.printStackTrace()
            }
        }
    }

    private fun onNewSocket(socket: SSLSocket) {
        try {
            socket.outputStream.bufferedWriter().apply {
                write(toJson(ConfigUtil.Device.getDeviceInfo()))
                flush()
            }
            val info = gson.fromJson(
                socket.inputStream.bufferedReader().readLine(),
                DeviceInfo::class.java
            ).copy(
                ip = socket.inetAddress.hostAddress ?: ""
            )
            DeviceProvider.create(
                context,
                info,
                socket
            )
        } catch (e: Exception) {
            errorLog("${this::class.simpleName}: Error connecting to ${socket.inetAddress.hostAddress}. Exception is:\n")
            e.printStackTrace()
        }
    }
}