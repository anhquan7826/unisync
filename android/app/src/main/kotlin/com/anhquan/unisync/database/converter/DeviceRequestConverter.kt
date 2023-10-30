package com.anhquan.unisync.database.converter

import androidx.room.TypeConverter
import com.anhquan.unisync.models.DeviceRequest
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.toJson

class DeviceRequestConverter {
    @TypeConverter
    fun fromObject(request: DeviceRequest?): String? {
        return request?.let { toJson(it) }
    }

    @TypeConverter
    fun toObject(data: String?): DeviceRequest? {
        return data?.let { fromJson(it, DeviceRequest::class.java) }
    }
}