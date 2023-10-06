package com.anhquan.unisync.repository

import com.anhquan.unisync.models.ClientInfo

interface ConfigRepository {
    val clientInfo: ClientInfo

    val packageName: String
}