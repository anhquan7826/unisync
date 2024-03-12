package com.anhquan.unisync.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.anhquan.unisync.database.entity.PairedDeviceEntity
import io.reactivex.rxjava3.core.Completable
import io.reactivex.rxjava3.core.Single

@Dao
interface PairedDeviceDao {
    @Query("SELECT * FROM paired_devices")
    fun getAll(): Single<List<PairedDeviceEntity>>

    @Query("SELECT * FROM paired_devices WHERE id = :id")
    fun get(id: String): Single<PairedDeviceEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun add(value: PairedDeviceEntity): Completable

    @Delete
    fun remove(value: PairedDeviceEntity): Completable

    @Query("DELETE FROM paired_devices WHERE id = :id")
    fun remove(id: String): Completable

    @Query("SELECT COUNT(id) FROM paired_devices WHERE id = :id")
    fun exist(id: String): Single<Int>

    @Query("SELECT * FROM paired_devices ORDER BY lastAccessed DESC LIMIT 1")
    fun getLastUsed(): Single<PairedDeviceEntity>

    @Query("UPDATE paired_devices SET lastAccessed = :lastAccessed WHERE id = :id")
    fun setLastUsed(id: String, lastAccessed: Long = System.currentTimeMillis()): Completable
}