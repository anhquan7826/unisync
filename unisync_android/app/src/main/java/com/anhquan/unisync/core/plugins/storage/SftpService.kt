package com.anhquan.unisync.core.plugins.storage

import android.app.Service
import android.content.Intent
import android.os.Environment
import android.os.IBinder
import com.anhquan.unisync.utils.NotificationUtil
import com.anhquan.unisync.utils.infoLog
import org.apache.sshd.common.file.virtualfs.VirtualFileSystemFactory
import org.apache.sshd.server.SshServer
import org.apache.sshd.server.auth.password.PasswordAuthenticator
import org.apache.sshd.server.keyprovider.SimpleGeneratorHostKeyProvider
import org.apache.sshd.server.session.ServerSession
import org.apache.sshd.server.shell.InteractiveProcessShellFactory
import org.apache.sshd.sftp.server.SftpSubsystemFactory
import java.io.File
import java.io.IOException
import java.nio.file.Paths

class SftpService : Service() {
    var started = false
        private set

    inner class SshPasswordAuthenticator : PasswordAuthenticator {
        override fun authenticate(
            username: String?,
            password: String?,
            session: ServerSession?
        ): Boolean {
            return username == "unisync" && password == "Abc@1234"
        }
    }

    private lateinit var sshd: SshServer
    private fun init() {
        val rootPath = Environment.getExternalStorageDirectory().path
        val path = "$rootPath/uniysnc"
        createDirIfNotExists(path)
        System.setProperty("user.home", rootPath)
        sshd = SshServer.setUpDefaultServer()
        sshd.port = 45667
        sshd.passwordAuthenticator = SshPasswordAuthenticator()
        val simpleGeneratorHostKeyProvider = SimpleGeneratorHostKeyProvider(
            Paths.get(
                "$path/ssh_host_rsa_key"
            )
        )
        sshd.keyPairProvider = simpleGeneratorHostKeyProvider
        sshd.shellFactory = InteractiveProcessShellFactory()
        val factory = SftpSubsystemFactory.Builder().build()
        sshd.subsystemFactories = listOf(factory)
        sshd.fileSystemFactory = VirtualFileSystemFactory(Paths.get(rootPath))
        simpleGeneratorHostKeyProvider.loadKeys(null)
    }

    private fun createDirIfNotExists(path: String) {
        val file = File(path)
        if (!file.exists()) file.mkdirs()
    }

    override fun onCreate() {
        super.onCreate()
        infoLog("Initializing SFTP Server...")
        init()
        infoLog("SFTP Server initialized!")
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        try {
            if (!started) {
                infoLog("Starting SFTP Server...")
                sshd.start()
                startForeground(3, NotificationUtil.buildSftpNotification(this))
                started = true
                infoLog("SFTP Server started!")
            }
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return START_STICKY
    }

    override fun onDestroy() {
        infoLog("SFTP Server stopped!")
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}