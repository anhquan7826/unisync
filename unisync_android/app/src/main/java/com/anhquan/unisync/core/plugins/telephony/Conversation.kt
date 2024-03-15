package com.anhquan.unisync.core.plugins.telephony

data class Conversation(
    val personNumber: String,
    val personName: String? = null,
    val messages: MutableList<Message> = mutableListOf()
) {
    data class Message(
        val timestamp: Long, val sender: String? = null, val content: String
    )

    override fun hashCode(): Int = personNumber.hashCode()
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Conversation

        if (personNumber != other.personNumber) return false
        if (personName != other.personName) return false
        return messages == other.messages
    }

    override fun toString(): String {
        return """
Conversation:
__person: $personNumber - ${personName ?: "unknown"}
__messages:
${
            messages.let {
                it.sortBy { m -> m.timestamp }
                it.joinToString("\n") { m ->
                    if (m.sender == null) "____ ${m.content}"
                    else "____${personName ?: personNumber}: ${m.content}"
                }
            }
        }
            """.trimIndent()
    }
}