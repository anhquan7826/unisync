package com.anhquan.unisync.features

import com.anhquan.unisync.extensions.text
import com.anhquan.unisync.models.ChannelResult
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.plugins.MdnsPlugin
import com.anhquan.unisync.plugins.UnisyncPlugin
import com.anhquan.unisync.utils.ChannelUtil
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.toMap

class PairingFeature : UnisyncFeature() {
    override fun checkAvailability() {
        isAvailable = handlers.keys.containsAll(
            listOf(
                UnisyncPlugin.PLUGIN_MDNS,
                UnisyncPlugin.PLUGIN_SOCKET
            )
        )
    }

    override fun handlePluginData() {
        (handlers[UnisyncPlugin.PLUGIN_MDNS] as MdnsPlugin.MdnsPluginHandler).apply {
            onServiceAdded = {
                ChannelUtil.PairingChannel.apply {
                    val device = fromJson(it.text, DeviceInfo::class.java)!!.copy(
                        ip = it.inet4Addresses.first().hostAddress!!
                    )
                    invoke(FLUTTER_ON_DEVICE_ADDED, toMap(device))
                }
            }
            onServiceRemoved = {
                ChannelUtil.PairingChannel.apply {
                    val device = fromJson(it.text, DeviceInfo::class.java)!!.copy(
                        ip = it.inet4Addresses.first().hostAddress!!
                    )
                    invoke(FLUTTER_ON_DEVICE_REMOVED, toMap(device))
                }
            }
        }
    }

    override fun handleMethodChannelCall() {
        ChannelUtil.PairingChannel.apply {
            addCallHandler(NATIVE_GET_DISCOVERED_DEVICES) { _, result ->
                (handlers[UnisyncPlugin.PLUGIN_MDNS] as MdnsPlugin.MdnsPluginHandler).getDiscoveredServices {
                    result.success(toMap(ChannelResult(
                        method = NATIVE_GET_DISCOVERED_DEVICES,
                        resultCode = ChannelResult.SUCCESS,
                        result = it.map { info ->
                            val device = fromJson(info.text, DeviceInfo::class.java)!!.copy(
                                ip = info.inet4Addresses.first().hostAddress!!
                            )
                            toMap(device)
                        }
                    )))
                }
            }
        }
    }
}