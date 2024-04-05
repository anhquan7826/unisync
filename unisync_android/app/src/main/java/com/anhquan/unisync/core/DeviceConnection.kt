package com.anhquan.unisync.core

import android.content.Context
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.ThreadHelper
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.gson
import com.anhquan.unisync.utils.infoLog
import com.anhquan.unisync.utils.runSingle
import com.anhquan.unisync.utils.runTask
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.schedulers.Schedulers
import java.io.BufferedReader
import java.io.ByteArrayInputStream
import java.io.OutputStream
import java.net.ServerSocket
import javax.net.ssl.SSLSocket

class DeviceConnection(
    val context: Context,
    private val socket: SSLSocket,
    private val onDisconnected: (() -> Unit)? = null
) {
    interface ConnectionListener {
        fun onMessage(message: DeviceMessage)

        fun onDisconnected()
    }

    private val reader: BufferedReader = socket.inputStream.bufferedReader()
    private var writer: OutputStream = socket.outputStream

    var connectionListener: ConnectionListener? = null

    private lateinit var inputStreamDisposable: Disposable
    private var isConnected = true

    val ipAddress: String get() = socket.inetAddress?.hostAddress ?: ""

    init {
        listenInputStream()
    }

    private fun listenInputStream() {
        inputStreamDisposable = runTask(task = {
            try {
                while (true) {
                    val message = reader.readLine()
                    if (message != null) {
                        it.onNext(message)
                    } else {
                        disconnect()
                        break
                    }
                }
            } catch (e: Exception) {
//                it.onError(e)
            }
        }, onResult = {
            fromJson(
                it, DeviceMessage::class.java
            )?.let { message ->
                connectionListener?.onMessage(
                    message
                )
            }
        })
    }

    fun send(message: DeviceMessage, data: ByteArray? = null) {
        if (isConnected) {
            runSingle(callback = {
                writer.apply {
                    if (data != null) {
                        runSingle(
                            subscribeOn = Schedulers.newThread()
                        ) {
                            ThreadHelper.run {
                                try {
                                    infoLog("Opening server socket for payload...")
                                    val payloadServer = ServerSocket(0)
//                                    payloadServer.bind(null)
                                    val payloadSize = data.size
                                    write(
                                        gson.toJson(
                                            message.copy(
                                                payload = DeviceMessage.Payload(
                                                    port = payloadServer.localPort,
                                                    size = payloadSize
                                                )
                                            )
                                        ).toByteArray(Charsets.UTF_8)
                                    )
                                    flush()
                                    infoLog("Payload socket waiting for connection...")
                                    val payloadSocket = payloadServer.accept()
                                    infoLog("Payload socket server found a connection!")
                                    val payloadOutput = payloadSocket.getOutputStream()
                                    val dataStream = ByteArrayInputStream(data)
                                    infoLog("Sending payload of size $payloadSize...")
                                    val buffer = ByteArray(4096)
                                    var byteRead = dataStream.read(buffer)
                                    var progress = 0
                                    while (byteRead != -1) {
                                        payloadOutput.write(buffer, 0, byteRead)
                                        progress += byteRead
                                        infoLog("Sending payload: ${(progress / payloadSize) * 100}%")
                                        byteRead = dataStream.read(buffer)
                                    }
                                    payloadOutput.flush()
                                    infoLog("Payload sent!")
                                } catch (e: Exception) {
                                    e.printStackTrace()
                                }
                            }
                        }
                    } else {
                        write(gson.toJson(message).toByteArray(Charsets.UTF_8))
                        flush()
                    }
                }
            }, onError = {
                disconnect()
            })
        }
    }

    private fun disconnect() {
        isConnected = false
        try {
            inputStreamDisposable.dispose()
            socket.close()
            onDisconnected?.invoke()
            connectionListener?.onDisconnected()
        } catch (_: Exception) {
        }
    }
}