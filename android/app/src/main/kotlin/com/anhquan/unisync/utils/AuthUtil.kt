package com.anhquan.unisync.utils

import java.security.KeyPairGenerator
import java.security.PrivateKey
import java.security.PublicKey

object AuthUtil {
    private const val algorithm = "RSA"

    private val generator = KeyPairGenerator.getInstance(algorithm)

    lateinit var privateKey: PrivateKey
        private set

    lateinit var publicKey: PublicKey
        private set

    init {
        generator.initialize(2048)
    }

    fun generateKeyPair() {
        val keyPair = generator.generateKeyPair()
        publicKey = keyPair.public
        privateKey = keyPair.private
    }
}