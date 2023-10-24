package com.anhquan.unisync.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.anhquan.unisync.database.converter.DeviceRequestConverter
import com.anhquan.unisync.database.dao.DeviceRequestDao

@Database(entities = [], version = 1)
@TypeConverters(DeviceRequestConverter::class)
abstract class UnisyncDatabase : RoomDatabase() {
    abstract fun deviceRequestDao(): DeviceRequestDao
}