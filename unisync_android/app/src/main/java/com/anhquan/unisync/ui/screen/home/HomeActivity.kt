package com.anhquan.unisync.ui.screen.home

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.viewModels
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Card
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.ModalDrawerSheet
import androidx.compose.material3.ModalNavigationDrawer
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TextField
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.rememberDrawerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.ColorMatrix
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.anhquan.unisync.R
import com.anhquan.unisync.constants.Status.*
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.ui.composables.SliderTile
import com.anhquan.unisync.ui.composables.SliderTileController
import com.anhquan.unisync.ui.composables.UDialog
import com.anhquan.unisync.ui.screen.home.run_command.RunCommandActivity
import com.anhquan.unisync.ui.screen.pair.PairActivity
import com.anhquan.unisync.ui.theme.setView
import com.anhquan.unisync.utils.gson
import kotlinx.coroutines.launch

class HomeActivity : ComponentActivity() {
    private val viewModel: HomeViewModel by viewModels()
    private val volumeController = SliderTileController()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val deviceInfo = gson.fromJson(intent.extras!!.getString("device"), DeviceInfo::class.java)
        viewModel.device = Device.of(deviceInfo)
        setView {
            HomeScreen()
        }
    }

    @OptIn(ExperimentalMaterial3Api::class)
    @SuppressLint("NewApi")
    @Composable
    private fun HomeScreen() {
        val scope = rememberCoroutineScope()
        val state by viewModel.state.collectAsState()
        volumeController.value = state.volume
        val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
        var unlinkDialog by remember { mutableStateOf(false) }
        var renameDialog by remember { mutableStateOf(false) }

        if (unlinkDialog) {
            UDialog(painter = painterResource(id = R.drawable.warning),
                title = stringResource(id = R.string.warning),
                cancelText = stringResource(id = R.string.cancel),
                confirmText = stringResource(id = R.string.confirm),
                onCancel = {
                    unlinkDialog = false
                },
                onConfirm = {
                    unlinkDialog = false
                    viewModel.unpair()
                }) {
                Text(stringResource(id = R.string.unpair_confirmation))
            }
        }

        if (renameDialog) {
            var textFieldValue by remember {
                mutableStateOf(viewModel.thisDeviceInfo.name)
            }
            UDialog(title = stringResource(R.string.rename_this_device),
                cancelText = stringResource(id = R.string.cancel),
                confirmText = stringResource(id = R.string.confirm),
                onCancel = {
                    renameDialog = false
                },
                onConfirm = {
                    renameDialog = false
                    viewModel.renameDevice(textFieldValue)
                }) {
                TextField(value = textFieldValue, onValueChange = {
                    textFieldValue = it
                }, keyboardActions = KeyboardActions(onDone = {
                    renameDialog = false
                    viewModel.renameDevice(textFieldValue)
                }), keyboardOptions = KeyboardOptions(
                    imeAction = ImeAction.Done
                )
                )
            }
        }

        ModalNavigationDrawer(drawerState = drawerState, drawerContent = {
            ModalDrawerSheet {
                Column(
                    modifier = Modifier
                        .weight(1F)
                        .padding(16.dp)
                        .verticalScroll(rememberScrollState())
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(
                                bottom = 32.dp
                            )
                    ) {
                        Image(
                            painterResource(R.drawable.smartphone),
                            contentDescription = null,
                            modifier = Modifier
                                .size(42.dp)
                                .padding(end = 8.dp)
                        )
                        Column(
                            modifier = Modifier.weight(1F),
                        ) {
                            Text(
                                stringResource(R.string.app_name),
                                fontSize = 22.sp,
                                fontWeight = FontWeight.Medium
                            )
                            Text(viewModel.thisDeviceInfo.name)
                        }
                        IconButton(onClick = {
                            renameDialog = true
                        }) {
                            Icon(painterResource(id = R.drawable.edit), contentDescription = null)
                        }
                    }
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(stringResource(R.string.devices))
                        TextButton(onClick = {
                            startActivity(Intent(this@HomeActivity, PairActivity::class.java))
                        }) {
                            Text(stringResource(R.string.manage))
                        }
                    }
                    viewModel.pairedDevices.forEach {
                        DeviceTile(device = it) {
                            viewModel.device = it
                            scope.launch {
                                drawerState.close()
                            }
                        }
                    }
                }

            }
        }) {
            Scaffold(
//                containerColor = Color.White,
                contentWindowInsets = WindowInsets(left = 16.dp, right = 16.dp),
//                modifier = Modifier.systemBarsPadding(),
                topBar = {
                    TopAppBar(title = {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Image(
                                painterResource(id = R.drawable.computer),
                                contentDescription = null,
                                colorFilter = if (state.isOnline) null else ColorFilter.colorMatrix(
                                    ColorMatrix().apply {
                                        setToSaturation(0f)
                                    }),
                                modifier = Modifier
                                    .size(42.dp)
                                    .padding(end = 8.dp)
                            )
                            Column {
                                Text(
                                    viewModel.device.info.name,
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.SemiBold
                                )
                                Text(
                                    if (state.isOnline) stringResource(R.string.connected) else stringResource(
                                        R.string.disconnected
                                    ), fontSize = 10.sp
                                )
                            }
                        }
                    }, navigationIcon = {
                        IconButton(onClick = {
                            scope.launch {
                                drawerState.apply {
                                    if (isClosed) open() else close()
                                }
                            }
                        }) {
                            Icon(painterResource(id = R.drawable.menu), contentDescription = null)
                        }
                    }, actions = {
//                        IconButton(onClick = {
//                            startActivity(Intent(this@HomeActivity, SettingsActivity::class.java))
//                        }) {
//                            Icon(
//                                painterResource(id = R.drawable.settings),
//                                contentDescription = null,
//                                modifier = Modifier.size(24.dp)
//                            )
//                        }
                        IconButton(onClick = { unlinkDialog = true }) {
                            Icon(painterResource(R.drawable.unlink), contentDescription = null)
                        }
                    })
                }) { padding ->
                if (state.isOnline) {
                    LazyVerticalGrid(
                        columns = GridCells.Fixed(2), modifier = Modifier.padding(padding)
                    ) {
                        item {
                            FeatureTile(
                                icon = painterResource(id = R.drawable.data_transfer),
                                title = "Send files",
                            ) {}
                        }
                        item {
                            FeatureTile(
                                icon = painterResource(id = R.drawable.clipboards),
                                title = "Send clipboard",
                            ) {
                                viewModel.sendClipboard()
                            }
                        }
                        item {
                            SliderTile(
                                controller = volumeController
                            ) {
                                viewModel.setVolume(it)
                            }
                        }
                        item {
                            FeatureTile(
                                icon = painterResource(id = R.drawable.command_line),
                                title = "Run command",
                            ) {
                                startActivity(Intent(
                                    this@HomeActivity, RunCommandActivity::class.java
                                ).apply {
                                    putExtra("device", gson.toJson(viewModel.device.info))
                                })
                            }
                        }
                        item {
                            FeatureTile(
                                icon = painterResource(id = R.drawable.ssh),
                                title = "SSH",
                            ) {

                            }
                        }
                        item {
                            FeatureTile(
                                icon = painterResource(id = R.drawable.remote_control),
                                title = "Remote desktop",
                            ) {

                            }
                        }
                    }
                } else {
                    Column(
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(padding)
                    ) {
                        Icon(
                            painterResource(id = R.drawable.error),
                            contentDescription = null,
                            tint = Color.Gray,
                            modifier = Modifier
                                .size(64.dp)
                                .padding(
                                    bottom = 12.dp
                                )
                        )
                        Text(
                            stringResource(R.string.device_offline),
                            color = Color.Gray,
                            fontSize = 12.sp,
                            textAlign = TextAlign.Center
                        )
                    }
                }
            }
        }
    }

    @Composable
    private fun FeatureTile(
        modifier: Modifier = Modifier, icon: Painter, title: String, onTap: () -> Unit
    ) {
        Card(
            shape = RoundedCornerShape(28.dp),
            modifier = modifier
                .padding(8.dp)
                .fillMaxWidth()
                .height(128.dp)
                .clip(RoundedCornerShape(12.dp))
                .clickable(
                    onClick = onTap
                )
        ) {
            Column(
                verticalArrangement = Arrangement.Center,
                modifier = Modifier
                    .fillMaxHeight()
                    .padding(16.dp)
            ) {
                Image(
                    icon,
                    contentDescription = null,
                    modifier = Modifier
                        .size(48.dp)
                        .padding(bottom = 8.dp)
                )
                Text(title)
            }
        }
    }

    @Composable
    fun DeviceTile(device: Device, onTap: () -> Unit) {
        ListItem(modifier = Modifier.clickable {
            onTap()
        }, leadingContent = {
            Image(
                painterResource(id = R.drawable.computer),
                contentDescription = null,
                colorFilter = if (device.isOnline) null else ColorFilter.colorMatrix(ColorMatrix().apply {
                    setToSaturation(0f)
                }),
                modifier = Modifier
                    .size(42.dp)
                    .padding(end = 8.dp)
            )
        }, headlineContent = {
            Text(device.info.name)
        }, supportingContent = {
            Text(
                if (device.isOnline) stringResource(R.string.connected) else stringResource(R.string.disconnected),
                fontSize = 12.sp,
                color = Color.Gray
            )
        })
    }
}