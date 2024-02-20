package com.anhquan.unisync.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import com.anhquan.unisync.database.entity.DeviceCommandEntity
import io.reactivex.rxjava3.core.Completable
import io.reactivex.rxjava3.core.Single

@Dao
interface DeviceCommandDao {
    @Query("SELECT * FROM device_commands WHERE deviceId=:deviceId")
    fun get(deviceId: String): Single<List<DeviceCommandEntity>>

    @Insert
    fun add(command: DeviceCommandEntity): Completable

    @Delete
    fun remove(command: DeviceCommandEntity): Completable
}