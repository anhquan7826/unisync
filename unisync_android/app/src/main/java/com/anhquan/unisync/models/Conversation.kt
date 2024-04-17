package com.anhquan.unisync.models

data class Conversation(
    val number: String,
    val name: String? = null,
    val messages: MutableList<Message> = mutableListOf()
) {
    data class Message(
        val timestamp: Long,
        val from: String? = null,
        val fromName: String? = null,
        val content: String
    )

    override fun hashCode(): Int = number.hashCode()
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Conversation

        if (number != other.number) return false
        if (name != other.name) return false
        return messages == other.messages
    }

    override fun toString(): String {
        return """
Conversation:
__person: $number - ${name ?: "unknown"}
__messages:
${
            messages.let {
                it.sortBy { m -> m.timestamp }
                it.joinToString("\n") { m ->
                    if (m.from == null) "____ ${m.content}"
                    else "____${name ?: number}: ${m.content}"
                }
            }
        }
            """.trimIndent()
    }
}