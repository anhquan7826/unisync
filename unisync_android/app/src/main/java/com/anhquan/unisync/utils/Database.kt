package com.anhquan.unisync.utils

import android.content.Context
import androidx.room.Room
import com.anhquan.unisync.database.UnisyncDatabase
import com.anhquan.unisync.database.dao.DeviceCommandDao
import com.anhquan.unisync.database.dao.PairedDeviceDao

object Database {
    private lateinit var db: UnisyncDatabase

    fun initialize(context: Context) {
        db = Room.databaseBuilder(
            context,
            UnisyncDatabase::class.java,
            "unisync-database"
        ).fallbackToDestructiveMigration().build()
    }

    val pairedDevice: PairedDeviceDao get() = db.pairedDeviceDao()

    val deviceCommand: DeviceCommandDao get() = db.deviceCommandDao()
}