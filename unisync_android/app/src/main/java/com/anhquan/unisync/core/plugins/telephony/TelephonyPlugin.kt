package com.anhquan.unisync.core.plugins.telephony

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.ContactsContract
import android.provider.Telephony
import android.telephony.SmsManager
import androidx.core.content.ContextCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.toMap

class TelephonyPlugin(device: Device) : UnisyncPlugin(device, DeviceMessage.Type.TELEPHONY),
    SmsReceiver.SmsListener {
    private val smsManager = context.getSystemService(SmsManager::class.java)

    init {
        SmsReceiver.addListener(this)
        SmsReceiver.startService(context)
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

    override val requiredPermission: List<String>
        get() {
            val p = mutableListOf<String>()
            if (ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.READ_CONTACTS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                p.add(Manifest.permission.READ_CONTACTS)
            }
            val sms = listOf(
                Manifest.permission.READ_SMS,
                Manifest.permission.SEND_SMS,
                Manifest.permission.RECEIVE_SMS,
            ).any {
                ContextCompat.checkSelfPermission(
                    context,
                    it
                ) == PackageManager.PERMISSION_GRANTED
            }
            if (!sms) {
                p.addAll(
                    listOf(
                        Manifest.permission.READ_SMS,
                        Manifest.permission.SEND_SMS,
                        Manifest.permission.RECEIVE_SMS
                    )
                )
            }
            return p
        }

    override fun onDispose() {
        SmsReceiver.removeListener(this)
        super.onDispose()
    }
}