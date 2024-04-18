package com.anhquan.unisync.core.plugins.telephony

import android.Manifest
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.ContactsContract
import android.provider.Telephony
import android.telephony.SmsManager
import androidx.core.content.ContextCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.Conversation
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.toMap

class TelephonyPlugin(device: Device) : UnisyncPlugin(device, DeviceMessage.Type.TELEPHONY),
    SmsReceiver.SmsListener {
    private object Method {
        const val GET_MESSAGES = "get_messages"
        const val SEND_MESSAGE = "send_message"
        const val GET_CONTACT = "get_contact"
        const val NEW_MESSAGE = "new_message"
    }

    private val smsManager = context.getSystemService(SmsManager::class.java)

    init {
        SmsReceiver.addListener(this)
        SmsReceiver.startService(context)
    }

    override fun listen(
        header: DeviceMessage.DeviceMessageHeader,
        data: Map<String, Any?>,
        payload: DeviceConnection.Payload?
    ) {
        when (header.method) {
            Method.GET_MESSAGES -> {
                sendResponse(
                    Method.GET_MESSAGES,
                    mapOf(
                        "conversations" to (getConversations() ?: listOf()).map {
                            toMap(it)
                        }.toList()
                    )
                )
            }
            Method.SEND_MESSAGE -> {
                val recipient = data["to"].toString()
                val content = data["content"].toString()
                // todo: cache message
                smsManager.sendTextMessage(recipient, null, content, null, null)
            }
            Method.GET_CONTACT -> {
                phoneNumberLookup(data["number"].toString()).let {
                    it["name"]
                }.apply {
                    sendResponse(
                        Method.GET_CONTACT,
                        mapOf(
                            "name" to this
                        )
                    )
                }
            }
        }
    }

    override fun onSmsReceived(message: Conversation.Message) {
        sendNotification(
            Method.NEW_MESSAGE,
            mapOf(
                "message" to toMap(
                    message.copy(
                        fromName = phoneNumberLookup(message.from!!)["name"]
                    )
                )
            )
        )
    }

    private fun getConversations(): List<Conversation>? {
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
                val name = number?.let { phoneNumberLookup(it)["name"] }
                val content = getString(bodyIndex)

                val conversation = result.find {
                    it.number == number
                } ?: Conversation(
                    number = number,
                    name = name,
                ).apply {
                    result.add(this)
                }
                conversation.messages.add(
                    Conversation.Message(
                        timestamp = timestamp.toLong(),
                        from = number,
                        content = content
                    )
                )
            }
        }
        cursor.close()
        return result
    }

    private fun phoneNumberLookup(number: String): Map<String, String> {
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
            return listOf(
                Manifest.permission.READ_SMS,
                Manifest.permission.SEND_SMS,
                Manifest.permission.RECEIVE_SMS,
                Manifest.permission.READ_CONTACTS
            ).filterNot {
                ContextCompat.checkSelfPermission(
                    context,
                    it
                ) == PackageManager.PERMISSION_GRANTED
            }
        }

    override fun onDispose() {
        SmsReceiver.removeListener(this)
        super.onDispose()
    }
}