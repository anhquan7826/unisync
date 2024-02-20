package com.anhquan.unisync.database.entity

import androidx.room.Entity

@Entity(
    tableName = "device_commands",
//    foreignKeys = [ForeignKey(
//        entity = PairedDeviceEntity::class,
//        parentColumns = arrayOf("id"),
//        childColumns = arrayOf("deviceId"),
//        onDelete = ForeignKey.CASCADE
//    )],
    primaryKeys = [
        "command",
        "deviceId"
    ]
)
data class DeviceCommandEntity(
    val command: String,
    val deviceId: String
)