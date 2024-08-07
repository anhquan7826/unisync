package com.anhquan.unisync.core.plugins.telephony

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.provider.Telephony
import com.anhquan.unisync.models.Conversation
import com.google.i18n.phonenumbers.PhoneNumberUtil

class SmsReceiver : BroadcastReceiver() {
    interface SmsListener {
        fun onSmsReceived(message: Conversation.Message)
    }

    companion object {
        private var isStarted: Boolean = false
        private val listeners = mutableListOf<SmsListener>()

        fun startService(context: Context) {
            if (isStarted) return
            context.registerReceiver(
                SmsReceiver(),
                IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
            )
            isStarted = true
        }

        fun addListener(listener: SmsListener) {
            if (!listeners.contains(listener)) listeners.add(listener)
        }

        fun removeListener(listener: SmsListener) {
            listeners.remove(listener)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION == intent.action) {
            for (smsMessage in Telephony.Sms.Intents.getMessagesFromIntent(intent)) {
                val timestamp = smsMessage.timestampMillis
                val content = smsMessage.messageBody
                val senderNumber = smsMessage.displayOriginatingAddress
                val util = PhoneNumberUtil.getInstance()
                listeners.forEach {
                    it.onSmsReceived(
                        Conversation.Message(
                        timestamp = timestamp,
                        from = senderNumber.let { n ->
                            try {
                                val parsed = util.parse(n, null)
                                parsed.nationalNumber.toString()
                            } catch (_: Exception) {
                                n
                            }
                        },
                        content = content
                    ))
                }
            }
        }
    }
}