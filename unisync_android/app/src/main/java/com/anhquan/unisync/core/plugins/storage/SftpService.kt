package com.anhquan.unisync.core.plugins.storage

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.Environment
import android.os.IBinder
import com.anhquan.unisync.utils.NotificationUtil
import com.anhquan.unisync.utils.RandomUtil
import com.anhquan.unisync.utils.errorLog
import com.anhquan.unisync.utils.infoLog
import org.apache.sshd.common.file.virtualfs.VirtualFileSystemFactory
import org.apache.sshd.server.SshServer
import org.apache.sshd.server.auth.password.PasswordAuthenticator
import org.apache.sshd.server.keyprovider.SimpleGeneratorHostKeyProvider
import org.apache.sshd.server.session.ServerSession
import org.apache.sshd.server.shell.InteractiveProcessShellFactory
import org.apache.sshd.sftp.server.SftpSubsystemFactory
import java.io.IOException
import java.nio.file.Paths

class SftpService : Service() {
    private var started = false

    inner class SftpServiceBinder : Binder() {
        private var bindCount = 0

        fun informBound() {
            bindCount++
        }

        fun informUnbound() {
            bindCount--
            if (bindCount <= 0) {
                stopSelf()
                bindCount = 0
            }
        }

        val username: String
            get() = authenticator.username

        val password: String
            get() = authenticator.password

        val port: Int
            get() = this@SftpService.port
    }

    inner class SshPasswordAuthenticator : PasswordAuthenticator {
        val username = "unisync"
        val password: String = RandomUtil.randomString(20)

        override fun authenticate(
            username: String?,
            password: String?,
            session: ServerSession?
        ): Boolean {
            return username == this.username && password == this.password
        }
    }
    private val startPort = 49152
    private val endPort = 65535

    private val binder = SftpServiceBinder()
    private lateinit var sshd: SshServer
    private lateinit var authenticator: SshPasswordAuthenticator
    var port = -1
        private set

    private fun initServer() {
        infoLog("Initializing SFTP Server...")
        val rootPath = Environment.getExternalStorageDirectory().path
        val dataPath = Environment.getDataDirectory().path
        System.setProperty("user.home", rootPath)
        authenticator = SshPasswordAuthenticator()
        sshd = SshServer.setUpDefaultServer()
        sshd.apply {

            passwordAuthenticator = authenticator
            keyPairProvider = SimpleGeneratorHostKeyProvider(
                Paths.get(
                    "$dataPath/ssh_host_rsa_key"
                )
            ).apply {
                loadKeys(null)
            }
            shellFactory = InteractiveProcessShellFactory()
            subsystemFactories = listOf(SftpSubsystemFactory.Builder().build())
            fileSystemFactory = VirtualFileSystemFactory(Paths.get(rootPath))
        }
        infoLog("SFTP Server initialized!")
    }

    private fun startServer() {
        try {
            if (!started) {
                port = startPort
                infoLog("Starting SFTP Server at port $port...")
                while (port <= endPort) {
                    try {
                        sshd.port = port
                        sshd.start()
                        break
                    } catch (_: Exception) {
                        infoLog("Port $port is not available, switching to port ${++port}...")
                    }
                }
                if (port > endPort) {
                    errorLog("Cannot start SFTP Server: all ports are busy!")
                } else {
                    startForeground(3, NotificationUtil.buildSftpNotification(this))
                    started = true
                    infoLog("SFTP Server started at port $port!")
                }
            } else {
                infoLog("SFTP Server is already started!")
            }
        } catch (e: IOException) {
            errorLog("Cannot start SFTP Server!")
            e.printStackTrace()
        }
    }

    override fun onCreate() {
        super.onCreate()
        initServer()
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        startServer()
        return START_STICKY
    }

    override fun onDestroy() {
        infoLog("SFTP Server stopped!")
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder {
        startServer()
        return binder
    }
}