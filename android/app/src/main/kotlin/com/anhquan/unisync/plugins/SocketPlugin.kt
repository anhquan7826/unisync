package com.anhquan.unisync.plugins

import com.anhquan.unisync.constants.NetworkPorts
import com.anhquan.unisync.extensions.addTo
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.errorLog
import com.anhquan.unisync.utils.infoLog
import com.anhquan.unisync.utils.runPeriodic
import com.anhquan.unisync.utils.runSingle
import com.anhquan.unisync.utils.runTask
import com.anhquan.unisync.utils.warningLog
import io.reactivex.rxjava3.disposables.CompositeDisposable
import java.io.BufferedReader
import java.io.BufferedWriter
import java.io.IOException
import java.net.Socket

object SocketPlugin {
    private val connections = mutableMapOf<String, SocketConnection>()

    fun create(ip: String): SocketConnection {
        return if (connections.containsKey(ip)) {
            warningLog("SocketPlugin: connection to $ip has already been established.")
            connections[ip]!!
        } else {
            infoLog("SocketPlugin: create new connection to $ip.")
            val connection = SocketConnection(ip)
            connections[ip] = connection
            connection
        }
    }

    class SocketConnection(val ip: String) {
        private lateinit var socket: Socket
        private lateinit var reader: BufferedReader
        private lateinit var writer: BufferedWriter

        private var onConnectListener: (() -> Unit)? = null
        private var onDisconnectListener: (() -> Unit)? = null
        private var incomingMessageListener: ((String) -> Unit)? = null

        private val disposables = CompositeDisposable()

        var isConnected: Boolean = false
            private set

        fun addOnConnectListener(callback: () -> Unit): SocketConnection {
            onConnectListener = callback
            return this
        }

        fun addOnDisconnectListener(callback: () -> Unit): SocketConnection {
            onDisconnectListener = callback
            return this
        }

        fun addOnIncomingMessageListener(callback: (String) -> Unit): SocketConnection {
            incomingMessageListener = callback
            return this
        }

        fun connect() {
            runSingle(
                callback = {
                    socket = Socket(ip, NetworkPorts.socketPort)
                    reader = socket.getInputStream().bufferedReader()
                    writer = socket.getOutputStream().bufferedWriter()
                    infoLog("SocketConnection@$ip: connected.")
                    isConnected = true
                    onConnectListener?.invoke()
                    listenInputStream()
                    listenState()
                },
                onError = {
                    errorLog("SocketConnection@$ip: cannot connect.\n${it.message}")
                }
            )
        }

        fun postMessage(message: String) {
            runSingle(
                callback = {
                    socket.getOutputStream().bufferedWriter().write(message)
                    debugLog("SocketConnection@$ip: posted message: '$message'.")
                },
                onError = {
                    errorLog("SocketConnection: cannot post message to $ip.\n${it.message}")
                }
            )
        }

        fun disconnect() {
            if (isConnected) {
                runSingle(
                    callback = {
                        socket.close()
                        isConnected = false
                        disposables.dispose()
                        onDisconnectListener?.invoke()
                        connections.remove(ip)
                        infoLog("SocketConnection@$ip: disconnected.")
                    },
                    onError = {
                        errorLog("SocketPlugin: cannot close connection to $ip.\n${it.message}")
                    }
                )
            } else {
                errorLog("SocketPlugin: connection has not been started.")
            }
        }

        private fun listenInputStream() {
            runTask(
                task = {
                    infoLog("SocketConnection@$ip: starting input stream listener.")
                    try {
                        val input = socket.getInputStream().bufferedReader()
                        while (true) {
                            val message = input.readLine() ?: continue
                            it.onNext(message)
                        }
                    } catch (e: IOException) {
                        it.onError(e)
                    }
                },
                onResult = {
                    debugLog("SocketConnection@$ip: incoming message: '$it'.")
                    incomingMessageListener?.invoke(it)
                },
                onError = {
                    disconnect()
                }
            ).addTo(disposables)
        }

        private fun listenState() {
            runPeriodic(2500) {
                if (!socket.isConnected) {
                    disconnect()
                }
            }.addTo(disposables)
        }
    }
}