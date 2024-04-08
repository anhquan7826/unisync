package com.anhquan.unisync.utils

import android.content.Context
import android.content.SharedPreferences
import androidx.room.Room
import com.anhquan.unisync.constants.SPKey
import com.anhquan.unisync.database.UnisyncDatabase
import com.anhquan.unisync.database.entity.DeviceCommandEntity
import com.anhquan.unisync.database.entity.PairedDeviceEntity
import com.anhquan.unisync.models.DeviceInfo

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
            ).listen {}
        }

        fun removePairedDevice(info: DeviceInfo) {
            database.pairedDeviceDao().remove(info.id).listen {}
        }

        fun getAllPairedDevices(callback: (List<DeviceInfo>) -> Unit) {
            database.pairedDeviceDao().getAll().listen { list ->
                callback(list.map {
                    DeviceInfo(
                        id = it.id, name = it.name, deviceType = it.type
                    )
                })
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
                    it.unpaired
                )
            }
        }

        fun getLastUsedDevice(
            callback: (com.anhquan.unisync.core.Device?) -> Unit
        ) {
            database.pairedDeviceDao().getLastUsed().listen(onError = {
                callback(null)
            }) {
                callback(
                    com.anhquan.unisync.core.Device.of(
                        DeviceInfo(
                            id = it.id, name = it.name, deviceType = it.type
                        )
                    )
                )
            }
        }

        fun setLastUsedDevice(device: com.anhquan.unisync.core.Device) {
            database.pairedDeviceDao().setLastUsed(
                id = device.info.id
            ).listen { }
        }
    }

    object Command {
        fun addCommand(deviceId: String, command: String) {
            database.deviceCommandDao().add(
                DeviceCommandEntity(
                    deviceId = deviceId, command = command
                )
            )
        }

        fun getAllCommands(deviceId: String, callback: (List<String>) -> Unit) {
            database.deviceCommandDao().get(deviceId).listen {
                callback(it.map { entity ->
                    entity.command
                })
            }
        }
    }
}