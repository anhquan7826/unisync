package com.anhquan.unisync.ui.composables

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.anhquan.unisync.R
import com.anhquan.unisync.ui.theme.colorSchemes
import com.anhquan.unisync.ui.theme.typography

@Composable
fun TitledButton(
    modifier: Modifier = Modifier,
    icon: Painter,
    title: String,
    onClick: () -> Unit
) {
    Column(
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = modifier.clickable(onClick = onClick)
    ) {
        Icon(
            painter = icon,
            contentDescription = null,
            tint = colorSchemes().primary,
            modifier = Modifier
                .clip(shape = CircleShape)
                .background(
                    color = colorSchemes().primaryContainer,
                )
                .padding(8.dp)
                .size(42.dp)
        )
        Text(
            text = title,
            style = typography().titleMedium,
            modifier = Modifier.padding(top = 8.dp)
        )
    }
}

@Composable
@Preview(showSystemUi = true)
fun TitledButtonPreview() {
    TitledButton(
        icon = painterResource(id = R.drawable.power_settings_new),
        title = "Shutdown"
    ) {

    }
}