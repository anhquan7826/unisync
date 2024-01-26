package com.anhquan.unisync.database.converter

import androidx.room.TypeConverter
import com.anhquan.unisync.utils.gson
import com.google.gson.reflect.TypeToken

class MapConverter {
    @TypeConverter
    fun fromString(value: String?): Map<String, Any> {
        if (value == null) {
            return emptyMap()
        }

        val type = object : TypeToken<Map<String, Any>>() {}.type
        return gson.fromJson(value, type)
    }

    @TypeConverter
    fun toString(extras: Map<String, Any>): String {
        return gson.toJson(extras)
    }
}