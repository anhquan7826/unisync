package com.anhquan.unisync.plugins

import android.content.Context
import com.anhquan.unisync.constants.NetworkPorts
import com.anhquan.unisync.extensions.addTo
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.errorLog
import com.anhquan.unisync.utils.infoLog
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

class SocketPlugin(override val pluginConnection: UnisyncPluginConnection) : UnisyncPlugin() {
    enum class ConnectionState {
        STATE_ERROR, STATE_DISCONNECTED
    }

    inner class SocketConnection {
        inner class SocketConnectionException : Exception() {
            override val message: String
                get() = "${this@SocketConnection::class.simpleName}@$ip: connection has closed!"
        }

        private var ip: String
        private lateinit var socket: Socket
        private lateinit var reader: BufferedReader
        private lateinit var writer: BufferedWriter

        private var stateListener: ((ConnectionState, String?) -> Unit)? = null
        private var messageListener: ((String) -> Unit)? = null

        private val disposables = CompositeDisposable()

        constructor(ip: String) {
            this.ip = ip
            connect()
        }

        constructor(socket: Socket) {
            this.socket = socket
            ip = socket.inetAddress.hostAddress ?: "null"
            connect()
        }

        var isConnected: Boolean = false
            private set

        fun addMessageListener(callback: (String) -> Unit) {
            messageListener = callback
        }

        fun addStateListener(callback: (ConnectionState, String?) -> Unit) {
            stateListener = callback
        }

        private fun connect() {
            runSingle(
                callback = {
                    if (!this::socket.isInitialized) {
                        socket = Socket(ip, NetworkPorts.serverPort)
                    }
                    reader = socket.getInputStream().bufferedReader()
                    writer = socket.getOutputStream().bufferedWriter()
                    infoLog("${this::class.simpleName}@$ip: connected.")
                    isConnected = true
                    listenInputStream()
                },
                onError = {
                    errorLog("${this::class.simpleName}@$ip: cannot connect.\n${it.message}")
                    isConnected = false
                }
            )
        }

        fun sendMessage(message: String) {
            if (isConnected) {
                runSingle(
                    callback = {
                        socket.getOutputStream().bufferedWriter().write(message)
                        debugLog("${this::class.simpleName}@$ip: posted message: '$message'.")
                    },
                    onError = {
                        errorLog("${this::class.simpleName}: cannot post message to $ip.\n${it.message}")
                        stateListener?.invoke(ConnectionState.STATE_ERROR, it.message)
                    }
                )
            } else {
                throw SocketConnectionException()
            }
        }

        fun disconnect() {
            if (isConnected) {
                runSingle(
                    callback = {
                        socket.close()
                        isConnected = false
                        disposables.dispose()
                        stateListener?.invoke(ConnectionState.STATE_DISCONNECTED, null)
                        connections.remove(ip)
                        infoLog("${this::class.simpleName}@$ip: disconnected.")
                    },
                    onError = {
                        errorLog("${this::class.simpleName}: cannot close connection to $ip.\n${it.message}")
                        stateListener?.invoke(ConnectionState.STATE_ERROR, it.message)
                    }
                )
            } else {
                errorLog("${this::class.simpleName}: connection has not been started.")
            }
        }

        private fun listenInputStream() {
            runTask(
                task = {
                    infoLog("${this::class.simpleName}@$ip: starting input stream listener.")
                    while (true) {
                        try {
                            val message = reader.readLine() ?: continue
                            it.onNext(message)
                        } catch (e: IOException) {
                            it.onError(e)
                        }
                    }

                },
                onResult = {
                    debugLog("${this::class.simpleName}@$ip: incoming message: '$it'.")
                    messageListener?.invoke(it)
                },
                onError = {
                    disconnect()
                }
            ).addTo(disposables)
        }
    }

    inner class SocketPluginHandler : UnisyncPluginHandler {
        fun getConnection(ip: String): SocketConnection {
            return if (connections.containsKey(ip)) {
                infoLog("${this::class.simpleName}: connection to $ip has already been established.")
                connections[ip]!!
            } else {
                infoLog("${this::class.simpleName}: create new connection to $ip.")
                val connection = SocketConnection(ip)
                connections[ip] = connection
                connection
            }
        }
    }

    override val pluginHandler: UnisyncPluginHandler = SocketPluginHandler()

    private lateinit var serverSocket: ServerSocket
    private val connections = mutableMapOf<String, SocketConnection>()

    private lateinit var disposable: Disposable

    override fun start(context: Context) {
        infoLog("${this::class.simpleName}: starting Socket plugin.")
        disposable = runTask<Socket>(
            task = {
                serverSocket = ServerSocket(NetworkPorts.serverPort)
                pluginConnection.onPluginStarted(pluginHandler)
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
                    // TODO: handle sub-connection from connected devices
                    warningLog("${this::class.simpleName}: server accepted an already established connection from $ip.")
                } else {
                    connections[ip] = SocketConnection(it)
                }
            },
            onError = {
                errorLog("${this::class.simpleName}: server error: ${it.message}")
                pluginConnection.onPluginError(Exception(it))
            }
        )
    }

    override fun stop() {
        runSingle(
            callback = {
                disposable.dispose()
                connections.apply {
                    values.forEach {
                        it.disconnect()
                    }
                    clear()
                }
                serverSocket.close()
                pluginConnection.onPluginStopped()
            },
            onError = {
                errorLog("${this::class.simpleName}: server error: ${it.message}")
                pluginConnection.onPluginError(Exception(it))
            }
        )
    }
}