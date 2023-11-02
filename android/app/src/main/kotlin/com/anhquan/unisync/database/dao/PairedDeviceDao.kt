package com.anhquan.unisync.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.anhquan.unisync.database.entity.PairedDeviceEntity
import com.anhquan.unisync.models.DeviceInfo
import io.reactivex.rxjava3.core.Completable
import io.reactivex.rxjava3.core.Single

@Dao
interface PairedDeviceDao {
    @Query("SELECT device FROM paired_devices")
    fun getAll(): Single<List<DeviceInfo>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun add(value: PairedDeviceEntity): Completable

    @Delete
    fun remove(value: PairedDeviceEntity): Completable
}