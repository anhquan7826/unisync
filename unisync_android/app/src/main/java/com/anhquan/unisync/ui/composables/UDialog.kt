package com.anhquan.unisync.ui.composables

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.Divider
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog

@Composable
fun UDialog(
    title: String,
    content: String,
    cancelText: String,
    confirmText: String,
    onCancel: () -> Unit,
    onDismiss: () -> Unit = onCancel,
    onConfirm: () -> Unit,
) {
    Dialog(
        onDismissRequest = onDismiss
    ) {
        Card(
            shape = RoundedCornerShape(12.dp)
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = title,
                    textAlign = TextAlign.Center,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.fillMaxWidth()
                )
                Divider(modifier = Modifier.fillMaxWidth())
                Text(
                    text = content,
                    fontSize = 16.sp,
                    modifier = Modifier.padding(
                        top = 16.dp,
                        bottom = 32.dp
                    )
                )
                Row {
                    TextButton(
                        modifier = Modifier
                            .padding(end = 4.dp)
                            .weight(1f),
                        onClick = onCancel
                    ) {
                        Text(cancelText)
                    }
                    TextButton(
                        modifier = Modifier
                            .padding(start = 4.dp)
                            .weight(1f),
                        onClick = onConfirm
                    ) {
                        Text(confirmText)
                    }
                }
            }
        }
    }
}
