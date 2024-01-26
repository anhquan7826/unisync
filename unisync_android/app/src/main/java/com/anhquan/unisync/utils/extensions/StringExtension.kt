package com.anhquan.unisync.utils.extensions

fun String.isIPv4(): Boolean {
    val ipv4Pattern = Regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$")
    return ipv4Pattern.matches(this)
}