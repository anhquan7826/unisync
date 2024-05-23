package com.anhquan.unisync.utils

import android.content.Context
import android.content.SharedPreferences
import androidx.room.Room
import com.anhquan.unisync.constants.SPKey
import com.anhquan.unisync.database.UnisyncDatabase
import com.anhquan.unisync.database.entity.DeviceCommandEntity
import com.anhquan.unisync.database.entity.PairedDeviceEntity
import com.anhquan.unisync.models.DeviceInfo
import io.reactivex.rxjava3.core.Completable
import io.reactivex.rxjava3.core.Single

object ConfigUtil {
    private lateinit var sharedPreferences: SharedPreferences
    private lateinit var database: UnisyncDatabase

    fun setup(context: Context) {
        sharedPreferences = context.getSharedPreferences(context.packageName, Context.MODE_PRIVATE)
        database = Room.databaseBuilder(
            context, UnisyncDatabase::class.java, "unisync-database"
        ).fallbackToDestructiveMigration().build()
    }

    object Device {
        fun getDeviceInfo(): DeviceInfo {
            return fromJson(
                sharedPreferences.getString(
                    SPKey.deviceInfo, ""
                )!!, DeviceInfo::class.java
            )!!
        }

        fun setDeviceInfo(info: DeviceInfo) {
            sharedPreferences.edit().putString(SPKey.deviceInfo, toJson(info)).apply()
        }

        fun addPairedDevice(info: DeviceInfo) {
            database.pairedDeviceDao().add(
                PairedDeviceEntity(
                    id = info.id, name = info.name, type = info.deviceType
                )
            ).execute()
        }

        fun removePairedDevice(info: DeviceInfo): Completable {
            return database.pairedDeviceDao().remove(info.id)
        }

        fun markDeviceUnpaired(info: DeviceInfo): Completable {
            return database.pairedDeviceDao().markUnpaired(info.id)
        }

        fun getAllPairedDevices(): Single<List<DeviceInfo>> {
            return database.pairedDeviceDao().getAll().map { entities ->
                entities.map {
                    DeviceInfo(
                        id = it.id, name = it.name, deviceType = it.type
                    )
                }
            }
        }

        fun isDevicePaired(info: DeviceInfo, callback: (Boolean) -> Unit) {
            database.pairedDeviceDao().exist(info.id).listen {
                callback(it == 1)
            }
        }

        fun getDeviceInfo(id: String, callback: (DeviceInfo?, Boolean?) -> Unit) {
            database.pairedDeviceDao().get(id).listen(onError = {
                callback(null, null)
            }) {
                callback(
                    DeviceInfo(
                        id = it.id, name = it.name, deviceType = it.type
                    ),
                    it.unpaired == 1
                )
            }
        }

        fun getLastUsedDevice(
            context: Context,
        ): Single<List<com.anhquan.unisync.core.Device>> {
            return database.pairedDeviceDao().getLastUsed().map {
                it.map { e ->
                    com.anhquan.unisync.core.Device.of(
                        context,
                        DeviceInfo(
                            id = e.id, name = e.name, deviceType = e.type
                        )
                    )
                }
            }
        }

        fun setLastUsedDevice(device: com.anhquan.unisync.core.Device) {
            database.pairedDeviceDao().setLastUsed(
                id = device.info.id
            ).execute()
        }
    }

    object Command {
        fun addCommand(deviceId: String, command: String):Completable {
            return database.deviceCommandDao().add(
                DeviceCommandEntity(
                    deviceId = deviceId, command = command
                )
            )
        }

        fun removeCommand(deviceId: String, command: String): Completable {
            return database.deviceCommandDao().remove(
                DeviceCommandEntity(
                    deviceId, command
                )
            )
        }

        fun getAllCommands(deviceId: String): Single<List<String>> {
            return database.deviceCommandDao().get(deviceId).map {
                it.map { e -> e.command }
            }
        }
    }
}