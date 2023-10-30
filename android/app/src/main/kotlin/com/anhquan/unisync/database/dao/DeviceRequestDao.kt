package com.anhquan.unisync.database.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import com.anhquan.unisync.database.entity.DeviceRequestEntity
import com.anhquan.unisync.models.DeviceRequest
import io.reactivex.rxjava3.core.Completable
import io.reactivex.rxjava3.core.Single

@Dao
interface DeviceRequestDao {
    @Insert
    fun push(value: DeviceRequestEntity): Completable

    @Query("SELECT request FROM device_request WHERE `order` = (SELECT MIN(id) FROM device_request) AND `id` = :id LIMIT 1")
    fun pop(id: String) : Single<DeviceRequest>

    @Query("SELECT COUNT(*) FROM device_request WHERE `id` = :id")
    fun count(id: String): Single<Int>
}