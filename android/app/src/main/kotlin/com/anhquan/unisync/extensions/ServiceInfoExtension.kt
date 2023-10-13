package com.anhquan.unisync.extensions

import java.nio.charset.StandardCharsets
import javax.jmdns.ServiceInfo

val ServiceInfo.text: String
    get() {
        return String(this.textBytes, StandardCharsets.UTF_8).removeRange(0, 1)
    }