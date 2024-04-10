package com.anhquan.unisync.core.plugins

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts

class PermissionRequestActivity : ComponentActivity() {
    private lateinit var launcher: ActivityResultLauncher<String>
    private lateinit var permission: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        permission = intent.extras!!.getString("permission")!!
        launcher = registerForActivityResult(ActivityResultContracts.RequestPermission()) {
            finish()
        }
    }

    override fun onStart() {
        super.onStart()
        launcher.launch(permission)
    }
}