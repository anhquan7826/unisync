package com.anhquan.unisync.core.plugins.ssh

import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.models.DeviceMessage.DeviceMessageHeader.Type.RESPONSE
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.listenCancellable
import io.reactivex.rxjava3.core.Completable
import io.reactivex.rxjava3.core.Single
import java.io.BufferedReader
import java.io.InputStreamReader

class SSHPlugin(private val device: Device) : UnisyncPlugin(device, DeviceMessage.Type.SSH) {
    private val client = SSHClient()

    private object Method {
        const val SETUP = "setup"
        const val GET_USERNAME = "get_username"
    }

    fun setup(): Completable {
        return Completable.create { emitter ->
            sendRequest(Method.SETUP)
            events.listenCancellable {
                if (it.header.type == RESPONSE && it.header.method == Method.SETUP) {
                    if (it.data["result"] == "success") {
                        emitter.onComplete()
                    } else {
                        emitter.onError(Exception(it.data["error"].toString()))
                    }
                    return@listenCancellable true
                }
                return@listenCancellable false
            }
        }
    }

    fun getUsername(): Single<String> {
        return Single.create { emitter ->
            sendRequest(Method.GET_USERNAME)
            events.listenCancellable {
                if (it.header.type == RESPONSE && it.header.method == Method.GET_USERNAME) {
                    emitter.onSuccess(it.data["username"].toString())
                    return@listenCancellable true
                }
                return@listenCancellable false
            }
        }
    }

    val sshConnected: Boolean get() = client.isReady

    fun connect(username: String, password: String): Boolean {
        return client.connect(address = device.ipAddress!!, username = username, password = password)
    }

    fun foo() {
        connect("anhquan7826", "quan7826")
        client.outputStream.write("echo hello".encodeToByteArray())
        val reader = BufferedReader(InputStreamReader(client.inputStream))
        while (true) {
            try {
                debugLog(reader.readLine())
            } catch (e: Exception) {
                e.printStackTrace()
                break
            }
        }
    }
}