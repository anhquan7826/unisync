package com.anhquan.unisync.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.anhquan.unisync.database.converter.DeviceInfoConverter
import com.anhquan.unisync.database.converter.MapConverter
import com.anhquan.unisync.database.dao.DeviceCommandDao
import com.anhquan.unisync.database.dao.PairedDeviceDao
import com.anhquan.unisync.database.entity.DeviceCommandEntity
import com.anhquan.unisync.database.entity.PairedDeviceEntity

@Database(
    entities = [PairedDeviceEntity::class, DeviceCommandEntity::class],
    version = 3,
    exportSchema = false
)
@TypeConverters(MapConverter::class, DeviceInfoConverter::class)
abstract class UnisyncDatabase : RoomDatabase() {
    abstract fun pairedDeviceDao(): PairedDeviceDao
    abstract fun deviceCommandDao(): DeviceCommandDao
}