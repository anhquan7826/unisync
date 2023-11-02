package com.anhquan.unisync.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.anhquan.unisync.models.DeviceInfo

@Entity(tableName = "paired_devices")
data class PairedDeviceEntity(
    @PrimaryKey val id: String,
    val device: DeviceInfo,
)
