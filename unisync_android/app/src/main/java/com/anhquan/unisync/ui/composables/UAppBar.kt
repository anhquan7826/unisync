package com.anhquan.unisync.ui.composables

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UAppBar(
    title: (@Composable () -> Unit),
    leading: Painter? = null,
    onLeadingPressed: (() -> Unit)? = null,
    actions: List<Painter> = listOf(),
    onActionPressed: List<() -> Unit> = listOf(),
) {
    TopAppBar(
        colors = TopAppBarDefaults.topAppBarColors(
            containerColor = Color.White
        ),
        windowInsets = WindowInsets(left = 16.dp, right = 16.dp),
        navigationIcon = {
            if (leading != null) {
                IconButton(
                    onClick = {
                        onLeadingPressed?.invoke()
                    },
                    enabled = onLeadingPressed != null
                ) {
                    Icon(
                        painter = leading,
                        contentDescription = null,
                        tint = Color.Unspecified,
                        modifier = Modifier.size(32.dp)
                    )
                }
            }
        },
        title = {
            Box(
                modifier = Modifier.padding(start = if (leading == null) 0.dp else 16.dp)
            ) {
                title()
            }
        },
        actions = {
            for (i in actions.indices) {
                IconButton(
                    onClick = {
                        onActionPressed[i].invoke()
                    }
                ) {
                    Icon(
                        actions[i],
                        null,
                        tint = Color.Unspecified,
                        modifier = Modifier.size(28.dp)
                    )
                }
            }
        },
        modifier = Modifier
    )
}
