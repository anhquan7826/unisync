package com.anhquan.unisync.ui.composables

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UDialog(
    painter: Painter? = null,
    title: String,
    cancelText: String,
    confirmText: String,
    onCancel: () -> Unit,
    onDismiss: () -> Unit = onCancel,
    onConfirm: () -> Unit,
    content: @Composable () -> Unit,
) {
    AlertDialog(onDismissRequest = onDismiss) {
        Card(
            shape = RoundedCornerShape(24.dp),
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                if (painter != null) Icon(
                    painter,
                    contentDescription = null,
                    tint = Color.Red,
                    modifier = Modifier.size(32.dp)
                )
                Text(
                    title,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Medium
                )
                Box(
                    modifier = Modifier.padding(
                        top = 16.dp, bottom = 16.dp
                    )
                ) {
                    content()
                }
                Row(
                    horizontalArrangement = Arrangement.End, modifier = Modifier.fillMaxWidth()
                ) {
                    TextButton(onClick = onCancel) {
                        Text(cancelText)
                    }
                    TextButton(onClick = onConfirm, modifier = Modifier.padding(start = 16.dp)) {
                        Text(confirmText)
                    }
                }
            }
        }
    }

}
