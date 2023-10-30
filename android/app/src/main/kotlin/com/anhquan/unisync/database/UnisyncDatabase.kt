package com.anhquan.unisync.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.anhquan.unisync.database.converter.DeviceRequestConverter
import com.anhquan.unisync.database.converter.MapConverter
import com.anhquan.unisync.database.dao.DeviceRequestDao
import com.anhquan.unisync.database.entity.DeviceRequestEntity

@Database(entities = [DeviceRequestEntity::class], version = 1)
@TypeConverters(DeviceRequestConverter::class, MapConverter::class)
abstract class UnisyncDatabase : RoomDatabase() {
    abstract fun deviceRequestDao(): DeviceRequestDao
}