package com.anhquan.unisync.repository.impl

import com.anhquan.unisync.models.ClientInfo
import com.anhquan.unisync.plugins.MdnsPlugin
import com.anhquan.unisync.plugins.SocketPlugin
import com.anhquan.unisync.repository.ConfigRepository
import com.anhquan.unisync.repository.PairingRepository

class PairingRepositoryImpl(private val configs: ConfigRepository) : PairingRepository {
    private var onClientAdded: ((ClientInfo) -> Unit)? = null
    private var onClientRemoved: ((ClientInfo) -> Unit)? = null

    override fun startDiscoveryService() {
        MdnsPlugin.addServiceInfo(
            configs.packageName,
            configs.clientInfo.toJson()
        )
    }

    override fun addDiscoveryListener(
        onClientAdded: (ClientInfo) -> Unit,
        onClientRemoved: (ClientInfo) -> Unit
    ) {
        this.onClientAdded = onClientAdded
        this.onClientRemoved = onClientRemoved
    }

    override fun connectClient(client: ClientInfo) {
        SocketPlugin.create(client.ip).addOnIncomingMessageListener {

        }.connect()
    }

    override fun requestPair(client: ClientInfo) {

    }
}