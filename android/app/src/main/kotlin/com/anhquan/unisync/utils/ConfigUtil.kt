package com.anhquan.unisync.utils

import android.content.Context
import android.content.SharedPreferences
import androidx.room.Room
import com.anhquan.unisync.constants.SPKey
import com.anhquan.unisync.database.UnisyncDatabase
import com.anhquan.unisync.database.entity.DeviceRequestEntity
import com.anhquan.unisync.database.entity.PairedDeviceEntity
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceRequest
import com.anhquan.unisync.utils.cryptography.RSAHelper
import java.security.PrivateKey
import java.security.PublicKey

object ConfigUtil {
    private lateinit var sharedPreferences: SharedPreferences
    private lateinit var database: UnisyncDatabase

    fun setup(context: Context) {
        sharedPreferences = context.getSharedPreferences(context.packageName, Context.MODE_PRIVATE)
        database = Room.databaseBuilder(
            context,
            UnisyncDatabase::class.java,
            "unisync-database"
        ).build()
    }

    object Authentication {
        private lateinit var publicKey: PublicKey
        private lateinit var publicKeyString: String
        private lateinit var privateKey: PrivateKey
        private lateinit var privateKeyString: String

        fun generateKeypair() {
            if (::publicKey.isInitialized) {
                return
            }
            if (sharedPreferences.getString(SPKey.publicKey, "")?.isNotEmpty() == true) {
                publicKeyString = sharedPreferences.getString(SPKey.publicKey, "")!!
                privateKeyString = sharedPreferences.getString(SPKey.privateKey, "")!!
                publicKey = RSAHelper.decodeRSAKey(publicKeyString) as PublicKey
                privateKey = RSAHelper.decodeRSAKey(privateKeyString, isPrivate = true) as PrivateKey
                return
            }
            val keypair = RSAHelper.generateKeypair()
            privateKey = keypair.private
            privateKeyString = RSAHelper.encodeRSAKey(privateKey, isPrivate = true)
            publicKey = keypair.public
            publicKeyString = RSAHelper.encodeRSAKey(publicKey)
            sharedPreferences
                .edit()
                .putString(SPKey.privateKey, privateKeyString)
                .putString(SPKey.publicKey, publicKeyString)
                .apply()
        }

        fun getPublicKey(): PublicKey {
            generateKeypair()
            return publicKey
        }

        fun getPublicKeyString(): String {
            generateKeypair()
            return publicKeyString
        }

        fun getPrivateKey(): PrivateKey {
            generateKeypair()
            return privateKey
        }

        fun getPrivateKeyString(): String {
            generateKeypair()
            return privateKeyString
        }
    }

    object Device {
        fun getDeviceInfo(): DeviceInfo {
            return fromJson(
                sharedPreferences.getString(
                    SPKey.deviceInfo,
                    ""
                )!!, DeviceInfo::class.java
            )!!
        }

        fun setDeviceInfo(info: DeviceInfo) {
            sharedPreferences.edit().putString(SPKey.deviceInfo, toJson(info)).apply()
        }

        fun getPairedDevices(onResult: (List<DeviceInfo>) -> Unit) {
            database.pairedDeviceDao().getAll().listen {
                onResult.invoke(it)
            }
        }

        fun addPairedDevice(device: DeviceInfo) {
            database.pairedDeviceDao().add(
                PairedDeviceEntity(
                    device.id,
                    device
                )
            )
        }

        fun removePairedDevice(device: DeviceInfo) {
            database.pairedDeviceDao().remove(
                PairedDeviceEntity(
                    device.id,
                    device
                )
            )
        }
    }

    object RequestQueue {
        fun push(id: String, request: DeviceRequest) {
            database.deviceRequestDao().push(DeviceRequestEntity(id = id, request = request))
        }

        fun pop(id: String, onResult: (DeviceRequest?) -> Unit) {
            database.deviceRequestDao().pop(id).listen(
                onResult = {
                    onResult(it)
                },
                onError = {
                    onResult(null)
                }
            )
        }

        fun isEmpty(id: String, onResult: (Boolean) -> Unit) {
            database.deviceRequestDao().count(id).listen {
                onResult(it == 0)
            }
        }
    }
}