package com.anhquan.unisync.utils

import com.google.gson.Gson
import com.google.gson.JsonSyntaxException
import kotlin.reflect.KClass
import kotlin.reflect.full.memberProperties

val gson = Gson()

fun <T : Any> toMap(obj: T): Map<String, Any?> {
    return (obj::class as KClass<T>).memberProperties.associate { prop ->
        prop.name to prop.get(obj)?.let { value ->
            if (value::class.isData) {
                toMap(value)
            } else {
                value
            }
        }
    }
}

fun toJson(obj: Any): String {
    return if (obj::class.isData) {
        gson.toJson(obj)
    } else {
        "{}"
    }
}

fun <T : Any> fromJson(json: String, type: Class<T>): T? {
    return try {
        gson.fromJson(json, type)
    } catch (e: JsonSyntaxException) {
        null
    }
}