package com.anhquan.unisync.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "paired_devices")
data class  PairedDeviceEntity(
    @PrimaryKey val id: String,
    val name: String,
    val type: String
)
