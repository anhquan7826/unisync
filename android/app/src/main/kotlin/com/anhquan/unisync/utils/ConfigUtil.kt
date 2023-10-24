package com.anhquan.unisync.utils

import android.content.Context
import android.content.SharedPreferences
import androidx.room.Room
import com.anhquan.unisync.constants.SPKey
import com.anhquan.unisync.database.UnisyncDatabase
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceRequest

object ConfigUtil {
    private lateinit var sharedPreferences: SharedPreferences
    private lateinit var database: UnisyncDatabase

    fun setup(context: Context) {
        sharedPreferences = context.getSharedPreferences(context.packageName, Context.MODE_PRIVATE)
        database = Room.databaseBuilder(
            context,
            UnisyncDatabase::class.java,
            "unisync-database"
        ).build()
    }

    object Device {
        fun getDeviceInfo(): DeviceInfo {
            return fromJson(
                sharedPreferences.getString(
                    SPKey.deviceInfo,
                    ""
                )!!, DeviceInfo::class.java
            )!!
        }

        fun setDeviceInfo(info: DeviceInfo) {
            sharedPreferences.edit().putString(SPKey.deviceInfo, toJson(info)).apply()
        }
    }

    object RequestQueue {
        fun push(id: String, request: DeviceRequest) {
            database.deviceRequestDao().push(id, request)
        }

        fun pop(id: String, onResult: (DeviceRequest?) -> Unit) {
            database.deviceRequestDao().pop(id).listen(
                onResult = {
                    onResult(it)
                },
                onError = {
                    onResult(null)
                }
            )
        }

        fun isEmpty(id: String, onResult: (Boolean) -> Unit) {
            database.deviceRequestDao().count(id).listen {
                onResult(it == 0)
            }
        }
    }
}