package com.anhquan.unisync.utils

object PortUtil {
    private val freePorts = ArrayDeque(listOf<Int>())
    private const val minPortNumber = 50000
    private var maxPortNumber = 50000

    fun releasePort(port: Int) {
        freePorts.addFirst(port)
    }

    fun getPort(): Int {
        return if (freePorts.isNotEmpty()) {
            freePorts.removeFirst()
        } else {
            maxPortNumber++
        }
    }
}