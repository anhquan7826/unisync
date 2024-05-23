package com.anhquan.unisync.core.plugins.storage

import android.Manifest
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.os.IBinder
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.models.UnisyncFile
import com.anhquan.unisync.utils.execute
import com.anhquan.unisync.utils.fromMap
import com.anhquan.unisync.utils.getPayloadData
import com.anhquan.unisync.utils.runSingle
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.core.Single
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream

class StoragePlugin(device: Device) : UnisyncPlugin(device, DeviceMessage.Type.STORAGE),
    ServiceConnection {
    private lateinit var serviceBinder: SftpService.SftpServiceBinder

    private object Method {
        const val START_SERVER = "start_server"
        const val STOP_SERVER = "stop_server"
        const val LIST_DIR = "list_dir"
        const val SEND_FILE = "send_file"
        const val GET_FILE = "get_file"
    }

    override fun listen(
        header: DeviceMessage.DeviceMessageHeader,
        data: Map<String, Any?>,
        payload: DeviceConnection.Payload?
    ) {
        super.listen(header, data, payload)
        when (header.method) {
            Method.START_SERVER -> {
                context.bindService(
                    Intent(context, SftpService::class.java),
                    this,
                    Context.BIND_AUTO_CREATE
                )
            }

            Method.STOP_SERVER -> {
                context.unbindService(this)
            }
        }
    }

    fun getDir(path: String): Single<List<UnisyncFile>> {
        return Single.create { emitter ->
            sendRequest(Method.LIST_DIR, mapOf("path" to path))
            events.execute {
                if (it.header.type == DeviceMessage.DeviceMessageHeader.Type.RESPONSE && it.header.method == Method.LIST_DIR) {
                    emitter.onSuccess(
                        (it.data["dir"] as List<*>).map { d ->
                            @Suppress("UNCHECKED_CAST")
                            fromMap(d as Map<String, Any?>, UnisyncFile::class.java)!!
                        }
                    )
                    return@execute true
                }
                return@execute false
            }
        }
    }

    fun getFile(file: UnisyncFile, onProgress: (Float) -> Unit) {
        if (!hasPermission) {
            Toast.makeText(
                context,
                "Please grant file access permission in home screen!",
                Toast.LENGTH_SHORT
            ).show()
            return
        }
        sendRequest(Method.GET_FILE, mapOf("path" to file.fullPath))
        events.execute {
            if (it.header.type == DeviceMessage.DeviceMessageHeader.Type.RESPONSE && it.header.method == Method.GET_FILE) {
                try {
                    val downloadsDir =
                        Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                    downloadsDir.mkdirs()
                    val f = File(downloadsDir, file.name)
                    val outputStream = FileOutputStream(f)
                    getPayloadData(it.payload!!, onProgress = onProgress, onDone = {
                        outputStream.close()
                        runSingle(
                            subscribeOn = AndroidSchedulers.mainThread()
                        ) {
                            Toast.makeText(
                                context,
                                "File saved to Downloads: ${file.name}",
                                Toast.LENGTH_SHORT
                            ).show()
                        }
                    }) { byteArray ->
                        outputStream.write(byteArray)
                    }
                } catch (e: IOException) {
                    e.printStackTrace()
                }
                return@execute true
            }
            return@execute false
        }
    }

    fun sendFile(fileName: String, fileSize: Long, fileStream: InputStream, destination: String, onProgress: (Float) -> Unit) {
        sendRequest(
            Method.SEND_FILE,
            mapOf(
                "destination" to destination,
                "name" to fileName,
                "size" to fileSize,
            ),
            DeviceConnection.Payload(
                fileStream,
                fileSize
            ),
            onProgress
        )
    }

    override fun onDispose() {
        try {
            context.unbindService(this)
        } catch (_: Exception) {}
        super.onDispose()
    }

    override val requiredPermission: List<String>
        get() {
            return listOf<String>().let {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && !Environment.isExternalStorageManager()) {
                    it.plus(Manifest.permission.MANAGE_EXTERNAL_STORAGE)
                } else {
                    it
                }
            }.filterNot {
                ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
            }
        }

    override fun onServiceConnected(name: ComponentName, service: IBinder) {
        serviceBinder = service as SftpService.SftpServiceBinder
        serviceBinder.informBound()
        sendResponse(
            Method.START_SERVER,
            mapOf(
                "port" to serviceBinder.port,
                "username" to serviceBinder.username,
                "password" to serviceBinder.password
            )
        )
    }

    override fun onServiceDisconnected(name: ComponentName) {
        serviceBinder.informUnbound()
    }
}