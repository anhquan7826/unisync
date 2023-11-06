package com.anhquan.unisync.utils.cryptography

import java.security.SecureRandom
import java.util.Base64
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec


object AESHelper {
    fun generateSecretKey(): SecretKey {
        val keyGenerator = KeyGenerator.getInstance("AES")
        keyGenerator.init(128)
        return keyGenerator.generateKey()
    }

    fun decodeSecretKey(keyString: String): SecretKey {
        val keyBytes = Base64.getDecoder().decode(keyString)
        return SecretKeySpec(keyBytes, "AES");
    }

    fun encodeSecretKey(secretKey: SecretKey): String {
        return Base64.getEncoder().encodeToString(secretKey.encoded)
    }

    fun encrypt(data: ByteArray, secretKey: SecretKey): ByteArray {
        val ivSpec = IvParameterSpec(generateIV())
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.ENCRYPT_MODE, secretKey, ivSpec)
        return cipher.doFinal(data)
    }

    fun decrypt(encryptedData: ByteArray, secretKey: SecretKey): ByteArray {
        val ivSpec = IvParameterSpec(generateIV())
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec)
        return cipher.doFinal(encryptedData)
    }

    private fun generateIV(length: Int = 16): ByteArray {
        val iv = ByteArray(length)
        SecureRandom().nextBytes(iv)
        return iv
    }
}