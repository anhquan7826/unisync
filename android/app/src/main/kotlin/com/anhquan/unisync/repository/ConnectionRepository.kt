package com.anhquan.unisync.repository

import com.anhquan.unisync.models.ClientInfo

interface ConnectionRepository {
    fun initiate()

    fun addListener(
        onClientAdded: (ClientInfo) -> Unit,
        onClientRemoved: (ClientInfo) -> Unit,
        onClientChanged: ((List<ClientInfo>) -> Unit)? = null
    )
}