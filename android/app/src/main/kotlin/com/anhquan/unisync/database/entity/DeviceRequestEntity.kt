package com.anhquan.unisync.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.anhquan.unisync.models.DeviceRequest

@Entity(tableName = "device_request")
data class DeviceRequestEntity(
    @PrimaryKey(autoGenerate = true) val order: Int = -1,
    val id: String,
    val request: DeviceRequest
)
