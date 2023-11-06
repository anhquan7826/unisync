package com.anhquan.unisync.utils.cryptography

import java.security.Key
import java.security.KeyFactory
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.PrivateKey
import java.security.PublicKey
import java.security.Signature
import java.security.spec.PKCS8EncodedKeySpec
import java.security.spec.X509EncodedKeySpec
import java.util.Base64
import javax.crypto.Cipher


object RSAHelper {
    fun generateKeypair(): KeyPair {
        val keyGen = KeyPairGenerator.getInstance("RSA").apply {
            initialize(2048)
        }
        return keyGen.genKeyPair()
    }

    fun encodeRSAKey(key: Key, isPrivate: Boolean = false): String {
        return if (isPrivate) {
            val keySpec = PKCS8EncodedKeySpec(key.encoded)
            Base64.getEncoder().encodeToString(keySpec.encoded)
        } else {
            val bytes = key.encoded
            Base64.getEncoder().encodeToString(bytes)
        }
    }

    fun decodeRSAKey(keyString: String, isPrivate: Boolean = false): Key {
        val bytes = Base64.getDecoder().decode(keyString)
        val keySpec = if (isPrivate) PKCS8EncodedKeySpec(bytes) else X509EncodedKeySpec(bytes)
        val keyFactory = KeyFactory.getInstance("RSA")
        return if (isPrivate) {
            keyFactory.generatePrivate(keySpec)
        } else {
            keyFactory.generatePublic(keySpec)
        }
    }

    fun encrypt(data: ByteArray, publicKey: PublicKey): ByteArray {
        val cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding")
        cipher.init(Cipher.ENCRYPT_MODE, publicKey)
        return cipher.doFinal(data)
    }

    fun decrypt(encryptedData: ByteArray, privateKey: PrivateKey): ByteArray {
        val cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding")
        cipher.init(Cipher.DECRYPT_MODE, privateKey)
        return cipher.doFinal(encryptedData)
    }

    fun sign(data: ByteArray, privateKey: PrivateKey): ByteArray {
        val signature = Signature.getInstance("SHA256withRSA")
        signature.initSign(privateKey)
        signature.update(data)
        return signature.sign()
    }

    fun verifySignature(data: ByteArray, signedData: ByteArray, publicKey: PublicKey): Boolean {
        val verifySignature = Signature.getInstance("SHA256withRSA")
        verifySignature.initVerify(publicKey)
        verifySignature.update(data)
        return verifySignature.verify(signedData)
    }
}