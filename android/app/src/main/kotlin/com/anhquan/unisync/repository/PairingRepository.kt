package com.anhquan.unisync.repository

import com.anhquan.unisync.models.ClientInfo

interface PairingRepository {
    fun startDiscoveryService()

    fun addDiscoveryListener(
        onClientAdded: (ClientInfo) -> Unit,
        onClientRemoved: (ClientInfo) -> Unit,
    )

    fun connectClient(client: ClientInfo)

    fun requestPair(client: ClientInfo)
}