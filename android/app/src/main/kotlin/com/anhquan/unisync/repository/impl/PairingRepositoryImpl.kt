package com.anhquan.unisync.repository.impl

import android.net.ConnectivityManager
import android.net.wifi.WifiManager
import android.net.wifi.WifiManager.MulticastLock
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.plugins.MdnsPlugin
import com.anhquan.unisync.repository.ConfigRepository
import com.anhquan.unisync.repository.PairingRepository
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.toJson

class PairingRepositoryImpl(
    private val configs: ConfigRepository,
    private val connectivityManager: ConnectivityManager,
    private val wifiManager: WifiManager
) :
    PairingRepository {
    private var onClientAdded: ((DeviceInfo) -> Unit)? = null
    private var onClientRemoved: ((DeviceInfo) -> Unit)? = null

    private lateinit var multicastLock: MulticastLock

    override fun startService() {
        val ip = connectivityManager
            .getLinkProperties(connectivityManager.activeNetwork)
            ?.linkAddresses
            ?.get(1)
            ?.address
            ?.hostAddress ?: "localhost"
        debugLog("${this::class.simpleName}: starting Mdns plugin on ip: $ip.")
        debugLog("${this::class.simpleName}: creating multicast lock.")
        multicastLock = wifiManager.createMulticastLock(configs.packageName)
        multicastLock.apply {
            setReferenceCounted(true)
            acquire()
            debugLog("${this@PairingRepositoryImpl::class.simpleName}: acquired multicast lock.")
        }
        MdnsPlugin.addServiceInfo(
            ip,
            configs.packageName,
            toJson(
                configs.deviceInfo.copy(
                    ip = ip
                )
            )
        )
        return MdnsPlugin.start()
    }

    override fun stopService() {
        if (this::multicastLock.isInitialized) multicastLock.release()
        debugLog("${this::class.simpleName}: released multicast lock.")
        return MdnsPlugin.stop()
    }

    override fun getDiscoveredDevices(): List<DeviceInfo> {
        return MdnsPlugin.getDiscoveredServices().mapNotNull {
            fromJson(it, DeviceInfo::class.java)
        }
    }

    override fun addListener(
        onClientAdded: (DeviceInfo) -> Unit,
        onClientRemoved: (DeviceInfo) -> Unit
    ) {
        this.onClientAdded = onClientAdded
        this.onClientRemoved = onClientRemoved
    }

    override fun requestPair(client: DeviceInfo) {

    }
}