package com.anhquan.unisync.database.converter

import androidx.room.TypeConverter
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.toJson

class DeviceInfoConverter {
    @TypeConverter
    fun fromObject(request: DeviceInfo?): String? {
        return request?.let { toJson(it.copy(ip = "")) }
    }

    @TypeConverter
    fun toObject(data: String?): DeviceInfo? {
        return data?.let { fromJson(it, DeviceInfo::class.java) }
    }
}