package com.anhquan.unisync.utils

import java.security.SecureRandom

object RandomUtil {
    private val secureRandom = SecureRandom()

    private val symbols = (
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
        "abcdefghijklmnopqrstuvwxyz" +
        "1234567890"
    ).toCharArray()

    fun randomString(length: Int): String {
        val buffer = CharArray(length)
        for (idx in 0 until length) {
            buffer[idx] = symbols[secureRandom.nextInt(symbols.size)]
        }
        return String(buffer)
    }
}