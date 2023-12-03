package com.anhquan.unisync.features

import com.anhquan.unisync.features.DeviceConnection.DeviceState.OFFLINE
import com.anhquan.unisync.features.DeviceConnection.DeviceState.ONLINE
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.plugins.MdnsPlugin
import com.anhquan.unisync.plugins.SocketPlugin
import com.anhquan.unisync.plugins.UnisyncPlugin
import com.anhquan.unisync.utils.ChannelUtil
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.cryptography.AESHelper
import com.anhquan.unisync.utils.cryptography.RSAHelper
import com.anhquan.unisync.utils.fromMap
import com.anhquan.unisync.utils.listen
import com.anhquan.unisync.utils.toMap
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.Disposable
import java.security.PublicKey

class PairingFeature : UnisyncFeature() {
    private val socketPluginHandler: SocketPlugin.SocketPluginHandler
        get() = handlers[UnisyncPlugin.PLUGIN_SOCKET] as SocketPlugin.SocketPluginHandler

    private val mdnsPluginHandler: MdnsPlugin.MdnsPluginHandler
        get() = handlers[UnisyncPlugin.PLUGIN_MDNS] as MdnsPlugin.MdnsPluginHandler

    override fun checkAvailability() {
        isAvailable = handlers.keys.containsAll(
            listOf(
                UnisyncPlugin.PLUGIN_MDNS,
                UnisyncPlugin.PLUGIN_SOCKET
            )
        )
    }

    private val inputObservers = mutableMapOf<String, Disposable>()

    override fun onFeatureReady() {
        DeviceConnection.connectionNotifier.listen(observeOn = AndroidSchedulers.mainThread()) {
            when (it.state) {
                ONLINE -> {
                    onDeviceConnected(it.deviceInfo)
                    inputObservers[it.deviceInfo.id] = DeviceConnection
                        .getConnection(it.deviceInfo.id)
                        .messageNotifier.listen { message ->
                            if (message.information == DeviceMessage.MessageInformation.DEVICE_PAIR_REQUEST) {
                                when (message.messageType) {
                                    DeviceMessage.REQUEST -> {
                                        onDevicePairRequest(message.data["id"]!!.toString())
                                    }

                                    DeviceMessage.RESPONSE -> {
                                        onDevicePairResponse(
                                            message.data["id"]!!.toString(),
                                            accepted = message.data["accepted"]!! == true
                                        )
                                    }

                                    DeviceMessage.STATUS -> {

                                    }
                                }
                            }
                        }
                }

                OFFLINE -> {
                    onDeviceDisconnected(it.deviceInfo)
                    inputObservers[it.deviceInfo.id]!!.dispose()
                    inputObservers.remove(it.deviceInfo.id)
                }

                else -> {}
            }
        }
    }

    override fun handlePluginData() {
        mdnsPluginHandler.apply {
            onServiceIpFound.listen {
                DeviceConnection.createConnection(socketPluginHandler.getConnection(it))
            }
        }
    }

    override fun handleMethodChannelCall() {
        ChannelUtil.PairingChannel.apply {
            addCallHandler(GET_CONNECTED_DEVICES) { _, emitter ->
                emitter.success(getConnectedDevices().map { toMap(it) })
            }
            addCallHandler(GET_PAIRED_DEVICES) { _, emitter ->
                getPairedDevices {
                    emitter.success(it.map { device -> toMap(device) })
                }
            }
            addCallHandler(GET_UNPAIRED_DEVICES) { _, emitter ->
                getUnpairedDevices {
                    emitter.success(it.map { device -> toMap(device) })
                }
            }
            addCallHandler(IS_DEVICE_ONLINE) { args, emitter ->
                val device = fromMap(args!!["device"] as Map<String, Any?>, DeviceInfo::class.java)
                if (device == null) {
                    emitter.error("Invalid device info")
                } else {
                    emitter.success(isDeviceOnline(device))
                }
            }
            addCallHandler(IS_DEVICE_PAIRED) { args, emitter ->
                val device = fromMap(args!!["device"] as Map<String, Any?>, DeviceInfo::class.java)
                if (device == null) {
                    emitter.error("Invalid device info")
                } else {
                    isDevicePaired(device) {
                        emitter.success(it)
                    }
                }
            }
            addCallHandler(SET_ACCEPT_PAIR) { args, emitter ->
                acceptPairRequest(args!!["id"].toString())
                emitter.success()
            }
            addCallHandler(SET_REJECT_PAIR) { args, emitter ->
                rejectPairRequest(args!!["id"].toString())
                emitter.success()
            }
        }
    }

    private fun onDeviceConnected(device: DeviceInfo) {
        ChannelUtil.PairingChannel.invoke(
            ChannelUtil.PairingChannel.ON_DEVICE_CONNECTED,
            args = mapOf(
                "device" to toMap(device)
            )
        )
    }

    private fun onDeviceDisconnected(device: DeviceInfo) {
        ChannelUtil.PairingChannel.invoke(
            ChannelUtil.PairingChannel.ON_DEVICE_DISCONNECTED,
            args = mapOf(
                "device" to toMap(device)
            )
        )
    }

    private fun getConnectedDevices(): List<DeviceInfo> {
        return DeviceConnection.getConnections().map { it.info }
    }

    private fun getPairedDevices(onComplete: (List<DeviceInfo>) -> Unit) {
        ConfigUtil.Device.getPairedDevices {
            val connectedDevices = getConnectedDevices()
            val devicesWithIP = it.map { device ->
                val info = connectedDevices.firstOrNull { info -> info.id == device.id }
                return@map if (info != null) {
                    // TODO: save this device if the persisted data is different (changed name or something else)
                    info
                } else {
                    device
                }
            }
            onComplete.invoke(devicesWithIP)
        }
    }

    private fun getUnpairedDevices(onComplete: (List<DeviceInfo>) -> Unit) {
        ConfigUtil.Device.getPairedDevices {
            val persistedId = it.map { device -> device.id }
            val connectedDevices = getConnectedDevices()
            onComplete.invoke(connectedDevices.filterNot { device ->
                persistedId.contains(device.id)
            })
        }
    }

    private fun isDeviceOnline(device: DeviceInfo): Boolean {
        return DeviceConnection.getConnections().any {
            it.info.id == device.id
        }
    }

    private fun isDevicePaired(device: DeviceInfo, result: (Boolean) -> Unit) {
        ConfigUtil.Device.getPairedDevices {
            result.invoke(it.any { persistedDevice -> persistedDevice.id == device.id })
        }
    }

    private fun onDevicePairRequest(deviceID: String) {
        ChannelUtil.PairingChannel.invoke(
            ChannelUtil.PairingChannel.ON_DEVICE_PAIR_REQUEST,
            args = mapOf("id" to deviceID)
        )
    }

    private fun onDevicePairResponse(deviceID: String, accepted: Boolean) {
        ChannelUtil.PairingChannel.invoke(
            ChannelUtil.PairingChannel.ON_DEVICE_PAIR_RESPONSE,
            args = mapOf(
                "id" to deviceID,
                "accepted" to accepted
            )
        )
        if (accepted) {
            exchangeSharedSecretKey(DeviceConnection.getConnection(deviceID))
        }
    }

    private fun acceptPairRequest(deviceID: String) {
        DeviceConnection.getConnection(deviceID).sendMessage(
            DeviceMessage(
                messageType = DeviceMessage.RESPONSE,
                information = DeviceMessage.MessageInformation.DEVICE_PAIR_RESULT,
                data = mapOf("accepted" to true)
            )
        )
        exchangeSharedSecretKey(DeviceConnection.getConnection(deviceID))
    }

    private fun rejectPairRequest(deviceID: String) {
        DeviceConnection.getConnection(deviceID).sendMessage(
            DeviceMessage(
                messageType = DeviceMessage.RESPONSE,
                information = DeviceMessage.MessageInformation.DEVICE_PAIR_RESULT,
                data = mapOf("accepted" to true)
            )
        )
    }

    private fun exchangeSharedSecretKey(connection: DeviceConnection) {
        val secretKey = AESHelper.generateSecretKey()
        connection.secretKey = secretKey
        val encodedSecretKey = AESHelper.encodeSecretKey(secretKey)
        val encryptedSecretKey = RSAHelper.encrypt(
            encodedSecretKey.toByteArray(), RSAHelper.decodeRSAKey(
                connection.info.publicKey
            ) as PublicKey
        )
        connection.sendMessage(
            DeviceMessage(
                messageType = DeviceMessage.STATUS,
                information = DeviceMessage.MessageInformation.SHARED_SECRET,
                data = mapOf("key" to encryptedSecretKey)
            )
        )
    }
}