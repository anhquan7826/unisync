package com.anhquan.unisync.ui.screen.home.run_command

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.viewModels
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import com.anhquan.unisync.R
import com.anhquan.unisync.constants.Status
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.ui.composables.UDialog
import com.anhquan.unisync.ui.theme.setView
import com.anhquan.unisync.utils.gson

class RunCommandActivity : ComponentActivity() {
    private lateinit var deviceInfo: DeviceInfo
    private val viewModel: RunCommandViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        deviceInfo = gson.fromJson(intent.extras!!.getString("device"), DeviceInfo::class.java)
        viewModel.deviceId = deviceInfo.id
        setView {
            RunCommandScreen()
        }
    }

    override fun onStart() {
        super.onStart()
        viewModel.getAll()
    }

    @OptIn(ExperimentalMaterial3Api::class)
    @Composable
    private fun RunCommandScreen() {
        val state by viewModel.state.collectAsState()
        var showAddDialog by remember {
            mutableStateOf(false)
        }
        if (showAddDialog) {
            AddCommandDialog(onDismiss = {
                showAddDialog = false
            }) {
                viewModel.add(it)
                showAddDialog = false
            }
        }
        if (state.status == Status.Loading) {
            CircularProgressIndicator()
        } else {
            Scaffold(topBar = {
                TopAppBar(title = {
                    Text(text = "Run Command")
                }, navigationIcon = {
                    IconButton(onClick = {
                        finish()
                    }) {
                        Icon(
                            painter = painterResource(id = R.drawable.arrow_back),
                            contentDescription = null
                        )
                    }
                }, actions = {
                    IconButton(onClick = { showAddDialog = true }) {
                        Icon(
                            painter = painterResource(id = R.drawable.add),
                            contentDescription = null
                        )
                    }
                })
            }) { padding ->
                LazyColumn(
                    modifier = Modifier.padding(padding)
                ) {
                    items(state.commands.toList()) {
                        ListItem(
                            headlineContent = {
                                Text(it)
                            },
                            modifier = Modifier.clickable {
                                viewModel.execute(it)
                            }
                        )
                    }
                }
            }
        }
    }

    @Composable
    private fun AddCommandDialog(onDismiss: () -> Unit, onAdd: (String) -> Unit) {
        var command by remember {
            mutableStateOf("")
        }
        UDialog(
            title = stringResource(R.string.add_new_command),
            cancelText = stringResource(id = R.string.cancel),
            confirmText = stringResource(R.string.add),
            onCancel = onDismiss,
            onConfirm = {
                onAdd(command)
            }) {
            TextField(value = command, onValueChange = {
                command = it
            })
        }
    }
}