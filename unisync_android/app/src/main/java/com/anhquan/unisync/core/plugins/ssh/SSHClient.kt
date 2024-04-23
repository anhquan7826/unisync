package com.anhquan.unisync.core.plugins.ssh

import com.jcraft.jsch.ChannelShell
import com.jcraft.jsch.JSch
import com.jcraft.jsch.JSchException
import com.jcraft.jsch.Session
import java.io.InputStream
import java.io.OutputStream

class SSHClient {
    companion object {
        const val MAX_CONNECTION_TIMEOUT = 60 * 1000
        const val MAX_OUTPUT_BUFFER_SIZE = 1024 * 8
        const val OUTPUT_BUFFER_DELAY_MS = 100L
    }

    private lateinit var session: Session
    private lateinit var channel: ChannelShell

    private val jSch = JSch().also {
//        it.addIdentity("${Environment.getDataDirectory().path}/ssh_host_rsa_key")
    }

    val inputStream: InputStream get() = channel.inputStream
    val outputStream: OutputStream get() = channel.outputStream

    val isReady: Boolean get() = this::channel.isInitialized

    fun connect(
        address: String,
        port: Int = 22,
        username: String,
        password: String
    ): Boolean {
        try {
            session = jSch.getSession(username, address, port).also {
                it.setPassword(password)
                it.setConfig("StrictHostKeyChecking", "no")
            }

            /* Connect the session */
            session.connect(MAX_CONNECTION_TIMEOUT)

            /* Initialize the shell channel */
            channel = (session.openChannel("shell") as ChannelShell)

            /* Connect the shell channel */
            channel.connect(MAX_CONNECTION_TIMEOUT)
            return true
        } catch (e: JSchException) {
            e.printStackTrace()
            return false
        }
    }

    fun disconnect() {
        if (this::channel.isInitialized)
            channel.disconnect()
        if (this::session.isInitialized)
            session.disconnect()
    }
}