package com.anhquan.unisync.database.converter

import androidx.room.TypeConverter
import com.anhquan.unisync.models.DeviceRequest
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.toJson

class DeviceRequestConverter {
    @TypeConverter
    fun fromObject(request: DeviceRequest): String {
        return toJson(request)
    }

    @TypeConverter
    fun toObject(data: String): DeviceRequest? {
        return fromJson(data, DeviceRequest::class.java)
    }
}