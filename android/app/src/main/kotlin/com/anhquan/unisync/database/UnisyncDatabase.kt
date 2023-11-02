package com.anhquan.unisync.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.anhquan.unisync.database.converter.DeviceInfoConverter
import com.anhquan.unisync.database.converter.DeviceRequestConverter
import com.anhquan.unisync.database.converter.MapConverter
import com.anhquan.unisync.database.dao.DeviceRequestDao
import com.anhquan.unisync.database.dao.PairedDeviceDao
import com.anhquan.unisync.database.entity.DeviceRequestEntity
import com.anhquan.unisync.database.entity.PairedDeviceEntity

@Database(entities = [DeviceRequestEntity::class, PairedDeviceEntity::class], version = 1)
@TypeConverters(DeviceRequestConverter::class, MapConverter::class, DeviceInfoConverter::class)
abstract class UnisyncDatabase : RoomDatabase() {
    abstract fun deviceRequestDao(): DeviceRequestDao
    abstract fun pairedDeviceDao(): PairedDeviceDao
}