package com.anhquan.unisync.core.plugins.run_command

import android.widget.Toast
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class RunCommandPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.RUN_COMMAND) {
    fun execute(command: String) {
        send(
            mapOf(
                "command" to command
            )
        )
        Toast.makeText(
            context,
            "Executing command '$command'...",
            Toast.LENGTH_SHORT
        ).show()
    }

    override fun onReceive(data: Map<String, Any?>) {}
}