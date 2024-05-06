package com.anhquan.unisync.ui.screen.home.file_transfer

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.pulltorefresh.PullToRefreshContainer
import androidx.compose.material3.pulltorefresh.rememberPullToRefreshState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.anhquan.unisync.R
import com.anhquan.unisync.constants.Status
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.UnisyncFile
import com.anhquan.unisync.ui.composables.DeviceDisconnected
import com.anhquan.unisync.ui.theme.defaultWindowInsets
import com.anhquan.unisync.ui.theme.setView
import com.anhquan.unisync.ui.theme.typography
import com.anhquan.unisync.utils.UnitFormatter
import com.anhquan.unisync.utils.gson

class FileTransferActivity : ComponentActivity() {
    private val viewModel: FileTransferViewModel by viewModels()

    private val filePickerLauncher =
        registerForActivityResult(ActivityResultContracts.OpenDocument()) {
            if (it != null) {
                viewModel.sendFile(this@FileTransferActivity, it)
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val deviceInfo = gson.fromJson(intent.extras!!.getString("device"), DeviceInfo::class.java)
        viewModel.initialize(Device.of(this, deviceInfo))
        setView {
            FileTransferScreen()
        }
    }

    @OptIn(ExperimentalMaterial3Api::class)
    @Composable
    private fun FileTransferScreen() {
        val state by viewModel.state.collectAsState()
        val pullToRefreshState = rememberPullToRefreshState()
        if (pullToRefreshState.isRefreshing) {
            LaunchedEffect(true) {
                viewModel.refresh()
                pullToRefreshState.endRefresh()
            }
        }

        Scaffold(
            modifier = Modifier.nestedScroll(pullToRefreshState.nestedScrollConnection),
            topBar = {
                TopAppBar(
                    title = {
                        Column {
                            Text(stringResource(id = R.string.browse_files))
                            Text(
                                state.path,
                                style = typography().labelMedium.copy(
                                    color = Color.Gray,
                                )
                            )
                        }
                    },
                    navigationIcon = {
                        IconButton(
                            onClick = { finish() }
                        ) {
                            Icon(
                                painterResource(id = R.drawable.arrow_back),
                                contentDescription = null
                            )
                        }
                    }
                )
            },
            floatingActionButton = {
                if (state.connected) {
                    FloatingActionButton(onClick = {
                        filePickerLauncher.launch(
                            arrayOf("*/*")
                        )
                    }) {
                        Icon(
                            painterResource(id = R.drawable.upload),
                            contentDescription = null
                        )
                    }
                }
            },
            contentWindowInsets = defaultWindowInsets()
        ) { padding ->
            if (!state.connected) {
                DeviceDisconnected()
            } else if (state.status == Status.Loading) {
                Box(
                    modifier = Modifier.fillMaxSize()
                ) {
                    CircularProgressIndicator(
                        modifier = Modifier.align(Alignment.Center)
                    )
                }
            } else {
                Box {
                    LazyColumn(
                        contentPadding = padding,
                        modifier = Modifier.fillMaxSize()
                    ) {
                        if (state.path != "/") {
                            item {
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .height(48.dp)
                                        .clickable {
                                            viewModel.goBack()
                                        }
                                ) {
                                    Text(
                                        "..",
                                        modifier = Modifier
                                            .align(Alignment.CenterStart)
                                            .padding(
                                                start = 22.dp
                                            )
                                    )
                                }
                            }
                        }
                        for (file in state.dir) {
                            item {
                                FileTile(file) {
                                    if (file.type != UnisyncFile.Type.FILE) {
                                        viewModel.goTo(file.name)
                                    } else {
                                        viewModel.saveFile(this@FileTransferActivity, file)
                                    }
                                }
                            }
                        }
                    }
                    PullToRefreshContainer(
                        state = pullToRefreshState,
                        modifier = Modifier.align(
                            Alignment.TopCenter
                        )
                    )
                }
            }
        }
    }

    @Composable
    fun FileTile(file: UnisyncFile, onClick: () -> Unit) {
        ListItem(
            headlineContent = {
                Text(file.name)
            },
            supportingContent = if (file.type == UnisyncFile.Type.FILE) {
                { Text(UnitFormatter.convertFileSize(file.size)) }
            } else null,
            leadingContent = {
                Icon(
                    when (file.type) {
                        UnisyncFile.Type.DIRECTORY -> painterResource(id = R.drawable.folder)
                        UnisyncFile.Type.FILE -> painterResource(id = R.drawable.description)
                        UnisyncFile.Type.SYMLINK -> painterResource(id = R.drawable.link)
                    },
                    contentDescription = null
                )
            },
            modifier = Modifier.clickable(onClick = onClick)
        )
    }
}