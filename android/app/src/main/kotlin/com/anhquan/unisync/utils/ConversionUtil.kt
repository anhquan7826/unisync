package com.anhquan.unisync.utils

import com.google.gson.Gson
import com.google.gson.JsonSyntaxException
import java.security.Key
import java.security.KeyFactory
import java.security.spec.PKCS8EncodedKeySpec
import java.security.spec.X509EncodedKeySpec
import java.util.Base64
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

fun keyToString(key: Key, isPrivate: Boolean = false): String {
    return if (isPrivate) {
        val keySpec = PKCS8EncodedKeySpec(key.encoded)
        Base64.getEncoder().encodeToString(keySpec.encoded)
    } else {
        val bytes = key.encoded
        Base64.getEncoder().encodeToString(bytes)
    }
}

fun stringToKey(keyString: String, isPrivate: Boolean = false): Key {
    val bytes = Base64.getDecoder().decode(keyString)
    val keySpec = if (isPrivate) PKCS8EncodedKeySpec(bytes) else X509EncodedKeySpec(bytes)
    val keyFactory = KeyFactory.getInstance("RSA")
    return if (isPrivate) {
        keyFactory.generatePrivate(keySpec)
    } else {
        keyFactory.generatePublic(keySpec)
    }
}