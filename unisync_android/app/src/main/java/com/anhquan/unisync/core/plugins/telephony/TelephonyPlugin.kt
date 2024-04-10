package com.anhquan.unisync.core.plugins.telephony

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Parcel
import android.os.Parcelable
import android.provider.ContactsContract
import android.provider.Telephony
import android.telephony.SmsManager
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.PermissionRequestActivity
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.toMap

class TelephonyPlugin(device: Device) : UnisyncPlugin(device, DeviceMessage.Type.TELEPHONY),
    SmsReceiver.SmsListener {
    private val smsManager = context.getSystemService(SmsManager::class.java)

    init {
        SmsReceiver.addListener(this)
        SmsReceiver.startService(context)
        getMessages()
    }

    override fun onReceive(data: Map<String, Any?>) {
        if (!hasPermission) return
        if (data.containsKey("get_messages")) {
            send(
                mapOf(
                    "messages" to getMessages()?.map {
                        toMap(it)
                    }?.toList()
                )
            )
        } else if (data.containsKey("send_message")) {
            val recipient = data["person"].toString()
            val content = data["content"].toString()
            // todo: cache message
            smsManager.sendTextMessage(recipient, null, content, null, null)
        }
    }

    override fun onSmsReceived(message: Conversation.Message) {
        send(
            mapOf("new_message" to toMap(message))
        )
    }

    private fun getMessages(): List<Conversation>? {
        val cursor =
            context.contentResolver.query(Telephony.Sms.Inbox.CONTENT_URI, null, null, null, null)
                ?: return null
        // todo: add cached messages and sort
        val result = mutableListOf<Conversation>()
        cursor.apply {
            debugLog(this.columnNames.joinToString(" - "))
            val timestampSentIndex = getColumnIndex(Telephony.Sms.Inbox.DATE_SENT)
            val timestampReceivedIndex = getColumnIndex(Telephony.Sms.Inbox.DATE)
            val numberIndex = getColumnIndex(Telephony.Sms.Inbox.ADDRESS)
            val bodyIndex = getColumnIndex(Telephony.Sms.Inbox.BODY)
            while (moveToNext()) {
                val timestamp = getString(timestampSentIndex) ?: getString(timestampReceivedIndex)
                val number = getString(numberIndex)
                val name = number?.let { phoneNumberLookup(context, it)["name"] }
                val content = getString(bodyIndex)

                val conversation = result.find {
                    it.personNumber == number
                } ?: Conversation(
                    personNumber = number,
                    personName = name,
                ).apply {
                    result.add(this)
                }
                conversation.messages.add(
                    Conversation.Message(
                        timestamp = timestamp.toLong(), sender = number, content = content
                    )
                )
            }
        }
        cursor.close()
        debugLog(result.joinToString("\n") {
            it.toString()
        })
        return result
    }

    private fun phoneNumberLookup(context: Context, number: String): Map<String, String> {
        val contactInfo = mutableMapOf<String, String>()
        val uri = Uri.withAppendedPath(
            ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(number)
        )
        val columns = arrayOf(
            ContactsContract.PhoneLookup.DISPLAY_NAME, ContactsContract.PhoneLookup.PHOTO_URI
        )
        try {
            context.contentResolver.query(uri, columns, null, null, null).use { cursor ->
                // Take the first match only
                if (cursor != null && cursor.moveToFirst()) {
                    var nameIndex = cursor.getColumnIndex(ContactsContract.PhoneLookup.DISPLAY_NAME)
                    if (nameIndex != -1) {
                        contactInfo["name"] = cursor.getString(nameIndex)
                    }
                    nameIndex = cursor.getColumnIndex(ContactsContract.PhoneLookup.PHOTO_URI)
                    if (nameIndex != -1) {
                        contactInfo["photoID"] = cursor.getString(nameIndex)
                    }
                }
            }
        } catch (ignored: Exception) {
        }
        return contactInfo
    }

    override val hasPermission: Boolean
        get() {
            val permissions = listOf(
                Manifest.permission.RECEIVE_SMS,
                Manifest.permission.READ_SMS,
                Manifest.permission.SEND_SMS,
                Manifest.permission.READ_CONTACTS
            )
            return permissions.all {
                ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
            }
        }

    override fun requestPermission(callback: (Boolean) -> Unit) {
        context.startActivity(Intent(context, PermissionRequestActivity::class.java).apply {
            setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra("permission", Manifest.permission.READ_CONTACTS)
        })
    }

    override fun onDispose() {
        SmsReceiver.removeListener(this)
        super.onDispose()
    }
}