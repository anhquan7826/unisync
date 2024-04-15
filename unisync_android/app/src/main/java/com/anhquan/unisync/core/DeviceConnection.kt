package com.anhquan.unisync.core

import android.content.Context
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.ThreadHelper
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.getPayloadStream
import com.anhquan.unisync.utils.gson
import com.anhquan.unisync.utils.infoLog
import com.anhquan.unisync.utils.runSingle
import com.anhquan.unisync.utils.runTask
import com.anhquan.unisync.utils.warningLog
import io.reactivex.rxjava3.disposables.Disposable
import java.io.BufferedReader
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.io.OutputStream
import java.net.ServerSocket
import javax.net.ssl.SSLSocket

class DeviceConnection(
    val context: Context,
    private val socket: SSLSocket,
    private val onDisconnected: (() -> Unit)? = null
) {
    interface ConnectionListener {
        fun onMessage(message: DeviceMessage, payload: Payload? = null)

        fun onDisconnected()
    }

    data class Payload(
        val stream: InputStream,
        val size: Int
    )

    private val reader: BufferedReader = socket.inputStream.bufferedReader()
    private var writer: OutputStream = socket.outputStream

    var connectionListener: ConnectionListener? = null

    private var isConnected = true

    val ipAddress: String get() = socket.inetAddress?.hostAddress ?: ""

    init {
        listenInputStream()
    }

    private fun listenInputStream() {
        runTask(task = {
            try {
                while (true) {
                    val message = reader.readLine()
                    if (message != null) {
                        it.onNext(message)
                    } else {
                        disconnect()
                        it.onComplete()
                        break
                    }
                }
            } catch (e: Exception) {
                it.onError(e)
            }
        }, onResult = {
            fromJson(
                it, DeviceMessage::class.java
            )?.let { message ->
                if (message.payload != null) {
                    getPayloadStream(
                        ipAddress,
                        message.payload.port
                    ) { stream ->
                        connectionListener?.onMessage(
                            message, Payload(
                                stream,
                                message.payload.size
                            )
                        )
                    }
                } else {
                    connectionListener?.onMessage(
                        message
                    )
                }
            }
        }, onError = {
            warningLog(it)
        })
    }

    fun send(message: DeviceMessage, data: ByteArray? = null) {
        if (isConnected) {
            runSingle(callback = {
                writer.apply {
                    if (data != null) {
                        ThreadHelper.run {
                            try {
                                infoLog("Opening server socket for payload...")
                                val payloadServer = ServerSocket(0)
                                val payloadSize = data.size
                                write(
                                    gson.toJson(
                                        message.copy(
                                            payload = DeviceMessage.DeviceMessagePayload(
                                                port = payloadServer.localPort,
                                                size = payloadSize
                                            )
                                        )
                                    ).toByteArray(Charsets.UTF_8)
                                )
                                flush()
                                infoLog("Payload socket waiting for connection at port ${payloadServer.localPort}...")
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
                                    infoLog(
                                        "Sending payload: ${
                                            String.format(
                                                "%.2f",
                                                progress.toDouble() / payloadSize * 100
                                            )
                                        }%"
                                    )
                                    byteRead = dataStream.read(buffer)
                                }
                                payloadOutput.flush()
                                infoLog("Payload sent!")
                            } catch (e: Exception) {
                                e.printStackTrace()
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
            socket.close()
            onDisconnected?.invoke()
            connectionListener?.onDisconnected()
        } catch (_: Exception) {
        }
    }
}