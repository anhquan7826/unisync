package com.anhquan.unisync.utils.extensions

import android.os.Bundle

fun Bundle.toPrettyString(): String {
    val entries = mutableListOf<String>()
    for (key in keySet()) {
        entries.add("  $key: ${get(key)}")
    }
    return """
Bundle {
${entries.joinToString("\n")}
}
    """.trimIndent()
}