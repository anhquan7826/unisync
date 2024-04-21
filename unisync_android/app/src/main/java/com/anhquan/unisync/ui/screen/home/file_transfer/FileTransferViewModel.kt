package com.anhquan.unisync.ui.screen.home.file_transfer

import android.annotation.SuppressLint
import android.net.Uri
import androidx.lifecycle.ViewModel
import com.anhquan.unisync.constants.Status
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.storage.StoragePlugin
import com.anhquan.unisync.models.UnisyncFile
import com.anhquan.unisync.utils.listenCancellable
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class FileTransferViewModel : ViewModel(), Device.DeviceEventListener {
    data class FileTransferState(
        val connected: Boolean = true,
        val status: Status = Status.Loading,
        val path: String = "/",
        val dir: List<UnisyncFile> = listOf()
    )

    private lateinit var device: Device

    private var _state = MutableStateFlow(FileTransferState())
    val state = _state.asStateFlow()

    private val _currentDir: String get() = _state.value.path

    fun initialize(device: Device) {
        this.device = device
        device.addEventListener(this)
        loadDir()
    }

    override fun onCleared() {
        device.removeEventListener(this)
        super.onCleared()
    }

    fun goTo(directory: String) {
        _state.update {
            it.copy(
                status = Status.Loading,
                path = append(directory),
            )
        }
        loadDir()
    }

    fun goBack() {
        _state.update {
            it.copy(
                status = Status.Loading,
                path = remove(),
            )
        }
        loadDir()
    }

    fun saveFile(file: UnisyncFile) {
        device.getPlugin(StoragePlugin::class.java).getFile(file) {

        }
    }

    @SuppressLint("Recycle")
    fun sendFile(uri: Uri) {
        device.getPlugin(StoragePlugin::class.java).sendFile(uri, _currentDir) {}
    }

    fun refresh() {
        _state.update {
            it.copy(
                status = Status.Loading,
            )
        }
        loadDir()
    }

    private fun loadDir() {
        device.getPlugin(StoragePlugin::class.java).getDir(_currentDir).listenCancellable { files ->
            _state.update {
                it.copy(
                    status = Status.Loaded,
                    dir = files
                )
            }
        }
    }

    private fun append(directory: String): String {
        return if (_currentDir.endsWith('/')) {
            "$_currentDir$directory"
        } else {
            "$_currentDir/$directory"
        }.trimEnd('/')
    }

    fun fullPath(name: String): String {
        val path = if (_currentDir.endsWith('/')) {
            "$_currentDir$name"
        } else {
            "$_currentDir/$name"
        }
        return path.trimEnd('/')
    }

    private fun remove(): String {
        val parts = _currentDir.split("/").filterNot { it.isEmpty() }
        return if (parts.isEmpty()) {
            "/"
        } else {
            "/${parts.subList(0, parts.size - 1).joinToString("/")}"
        }
    }

    override fun onDeviceEvent(event: Device.DeviceEvent) {
        _state.update {
            it.copy(
                connected = event.connected
            )
        }
        if (event.connected) {
            _state.update {
                it.copy(
                    status = Status.Loading,
                )
            }
            loadDir()
        }
    }
}