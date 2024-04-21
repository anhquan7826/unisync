package com.anhquan.unisync.utils

object UnitFormatter {
    fun convertFileSize(size: Long): String {
        var fileSize = size;
        if (fileSize <= 0) return "0 B"

        val units = arrayOf("B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB")
        var index = 0
        while (fileSize >= 1024 && index < units.lastIndex) {
            fileSize /= 1024
            index++
        }
        return String.format("%.2f %s", fileSize.toDouble(), units[index])
    }
}