package com.anhquan.unisync.models

import com.google.gson.annotations.SerializedName

data class UnisyncFile(
    val name: String,
    val type: Type,
    val size: Long,
    val fullPath: String,
) {
    enum class Type {
        @SerializedName("directory")
        DIRECTORY,

        @SerializedName("file")
        FILE,

        @SerializedName("symlink")
        SYMLINK,
    }
}