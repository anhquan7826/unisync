package com.anhquan.unisync.plugins

import android.content.Context
import com.anhquan.unisync.constants.NetworkPorts
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.errorLog
import com.anhquan.unisync.utils.infoLog
import com.anhquan.unisync.utils.runSingle
import com.anhquan.unisync.utils.runTask
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.subjects.ReplaySubject
import java.io.BufferedReader
import java.io.BufferedWriter
import java.net.Socket

class SocketPlugin(override val pluginConnection: UnisyncPluginConnection) : UnisyncPlugin() {
    enum class ConnectionState {
        STATE_CONNECTED, STATE_DISCONNECTED
    }

    inner class SocketConnection(val address: String) {
        private lateinit var socket: Socket
        private lateinit var reader: BufferedReader
        private lateinit var writer: BufferedWriter

        private lateinit var inputStreamDisposable: Disposable

        val connectionState: ReplaySubject<ConnectionState> = ReplaySubject.create()
        val inputStream: ReplaySubject<String> = ReplaySubject.create()

        var isConnected: Boolean = false
            private set

        fun connect() {
            runSingle(
                callback = {
                    if (!this::socket.isInitialized) {
                        socket = Socket(address, NetworkPorts.serverPort)
                        socket.keepAlive = true
                    }
                    reader = socket.getInputStream().bufferedReader()
                    writer = socket.getOutputStream().bufferedWriter()
                    infoLog("${this::class.simpleName}@$address: connected.")
                    isConnected = true
                    connectionState.onNext(ConnectionState.STATE_CONNECTED)
                    listenInputStream()
                },
                onError = {
                    errorLog("${this::class.simpleName}@$address: cannot connect.\n${it.message}")
                    isConnected = false
                    connectionState.onNext(ConnectionState.STATE_DISCONNECTED)
                }
            )
        }

        fun send(message: String) {
            if (isConnected) {
                runSingle(
                    callback = {
                        writer.apply {
                            write(message)
                            this.flush()
                        }
                        debugLog("${this::class.simpleName}@$address: Sent message: '$message'.")
                    },
                    onError = {
                        errorLog("${this::class.simpleName}: cannot post message to $address.\n${it.message}")
                        connectionState.onError(it)
                    }
                )
            } else {
                throw Exception("${this@SocketConnection::class.simpleName}@$address: connection has closed!")
            }
        }

        fun disconnect() {
            if (isConnected) {
                isConnected = false
                runSingle(
                    callback = {
                        inputStreamDisposable.dispose()
                        socket.close()
                        connectionState.onNext(ConnectionState.STATE_DISCONNECTED)
                        infoLog("${this::class.simpleName}@$address: disconnected.")
                    },
                    onError = {
                        errorLog("${this::class.simpleName}: cannot close connection to $address.\n${it.message}")
                        connectionState.onError(it)
                    }
                )
            } else {
                infoLog("${this::class.simpleName}: connection to $address has not been started.")
            }
        }

        private fun listenInputStream() {
            inputStreamDisposable = runTask(
                task = {
                    infoLog("${this::class.simpleName}@$address: starting input stream listener.")
                    while (true) {
                        val message = reader.readLine()
                        if (message != null) {
                            it.onNext(message)
                        } else {
                            disconnect()
                            break
                        }
                    }
                },
                onResult = {
                    debugLog("${this::class.simpleName}@$address: Received message: '$it'.")
                    if (isConnected) inputStream.onNext(it)
                }
            )
        }
    }

    inner class SocketPluginHandler : UnisyncPluginHandler {
        fun getConnection(ip: String): SocketConnection {
            infoLog("${this::class.simpleName}: create new connection to $ip.")
            return SocketConnection(ip)
        }
    }

    override val pluginHandler: UnisyncPluginHandler = SocketPluginHandler()

    override fun start(context: Context) {
        infoLog("${this::class.simpleName}: starting Socket plugin.")
        pluginConnection.onPluginStarted(pluginHandler)
    }

    override fun stop() {
        pluginConnection.onPluginStopped()
    }
}