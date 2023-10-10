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
import io.reactivex.rxjava3.disposables.Disposable
import java.io.BufferedReader
import java.io.BufferedWriter
import java.io.IOException
import java.net.ServerSocket
import java.net.Socket

object SocketPlugin {
    private lateinit var serverSocket: ServerSocket
    private lateinit var serverListenerDisposable: Disposable
    private val connections = mutableMapOf<String, SocketConnection>()

    fun getConnection(ip: String): SocketConnection {
        return if (connections.containsKey(ip)) {
            infoLog("${this::class.qualifiedName}: connection to $ip has already been established.")
            connections[ip]!!
        } else {
            infoLog("${this::class.qualifiedName}: create new connection to $ip.")
            val connection = SocketConnection(ip)
            connections[ip] = connection
            connection
        }
    }

    fun startServer() {
        serverListenerDisposable = runTask<Socket>(
            task = {
                serverSocket = ServerSocket(NetworkPorts.socketServerPort)
                while (true) {
                    try {
                        val socket = serverSocket.accept()
                        it.onNext(socket)
                    } catch (e: Throwable) {
                        it.onError(e)
                    }
                }
            },
            onResult = {
                val ip = it.inetAddress.hostAddress!!
                if (connections.containsKey(ip)) {
                    warningLog("${this::class.qualifiedName}: server accepted an already established connection from $ip.")
                } else {
                    connections[ip] = SocketConnection(it)
                }
            },
            onError = {
                errorLog("${this::class.qualifiedName}: server error: ${it.message}")
            }
        )
    }

    fun stopServer() {
        runSingle(
            callback = {
                serverSocket.close()
                serverListenerDisposable.dispose()
                infoLog("${this::class.qualifiedName}: server closed.")
            },
            onError = {
                errorLog("${this::class.qualifiedName}: cannot stop server.\n${it.message}")
            }
        )
    }

    class SocketConnection {
        private var ip: String
        private lateinit var socket: Socket
        private lateinit var reader: BufferedReader
        private lateinit var writer: BufferedWriter

        private var onConnectListener: (() -> Unit)? = null
        private var onDisconnectListener: (() -> Unit)? = null
        private var incomingMessageListener: ((String) -> Unit)? = null

        private val disposables = CompositeDisposable()

        constructor(ip: String) {
            this.ip = ip
        }

        constructor(socket: Socket) {
            this.socket = socket
            this.ip = socket.inetAddress.hostAddress ?: "null"
        }

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
                    if (!this::socket.isInitialized) {
                        socket = Socket(ip, NetworkPorts.socketClientPort)
                    }
                    reader = socket.getInputStream().bufferedReader()
                    writer = socket.getOutputStream().bufferedWriter()
                    infoLog("${this::class.qualifiedName}@$ip: connected.")
                    isConnected = true
                    onConnectListener?.invoke()
                    listenInputStream()
                    listenState()
                },
                onError = {
                    errorLog("${this::class.qualifiedName}@$ip: cannot connect.\n${it.message}")
                }
            )
        }

        fun postMessage(message: String) {
            runSingle(
                callback = {
                    socket.getOutputStream().bufferedWriter().write(message)
                    debugLog("${this::class.qualifiedName}@$ip: posted message: '$message'.")
                },
                onError = {
                    errorLog("${this::class.qualifiedName}: cannot post message to $ip.\n${it.message}")
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
                        infoLog("${this::class.qualifiedName}@$ip: disconnected.")
                    },
                    onError = {
                        errorLog("${this::class.qualifiedName}: cannot close connection to $ip.\n${it.message}")
                    }
                )
            } else {
                errorLog("${this::class.qualifiedName}: connection has not been started.")
            }
        }

        private fun listenInputStream() {
            runTask(
                task = {
                    infoLog("${this::class.qualifiedName}@$ip: starting input stream listener.")
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
                    debugLog("${this::class.qualifiedName}@$ip: incoming message: '$it'.")
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