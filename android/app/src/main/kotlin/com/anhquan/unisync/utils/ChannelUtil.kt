package com.anhquan.unisync.utils

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object ChannelUtil {
    private const val authority = "com.anhquan.unisync.channel"
    private lateinit var engine: FlutterEngine

    fun setup(engine: FlutterEngine) {
        ChannelUtil.engine = engine
    }

    open class ChannelHandler(private val path: String) {
        private val channel = MethodChannel(engine.dartExecutor.binaryMessenger, authority + path)

        private val callHandlers =
            mutableMapOf<String, (Map<String, Any?>?, MethodChannel.Result) -> Unit>()

        init {
            channel.setMethodCallHandler { call, result ->
                if (callHandlers.containsKey(call.method)) {
                    callHandlers[call.method]!!.invoke(call.arguments as Map<String, Any?>?, result)
                } else {
                    errorLog("${this::class.simpleName}@${call.method}: not implemented.")
                }
            }
        }

        fun invoke(
            method: String,
            args: Map<String, Any?>? = null,
            onError: (String?) -> Unit = { errorLog("${this::class.simpleName}: error: $it") },
            onResult: ((Any?) -> Unit)? = null,
        ) {
            channel.invokeMethod(method, args, object : MethodChannel.Result {
                override fun success(result: Any?) {
                    onResult?.invoke(result)
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    onError.invoke("${this::class.simpleName}@$method: error: $errorMessage")
                }

                override fun notImplemented() {
                    onError.invoke("${this::class.simpleName}@$method: method not implemented.")
                }
            })
        }

        fun addCallHandler(
            call: String,
            handler: (Map<String, Any?>?, MethodChannel.Result) -> Unit
        ) {
            callHandlers[call] = handler
            debugLog("${this::class.simpleName}@$call: added handler.")
        }

        fun removeCallHandler(call: String) {
            callHandlers.remove(call)
            debugLog("${this::class.simpleName}@$call: removed handler.")
        }
    }

    object PairingChannel : ChannelHandler("/connection") {
        const val FLUTTER_ON_DEVICE_ADDED = "on_device_added"
        const val FLUTTER_ON_DEVICE_REMOVED = "on_device_removed"
        const val NATIVE_START_DISCOVERY_SERVICE = "start_discovery_service"
        const val NATIVE_STOP_DISCOVERY_SERVICE = "stop_discovery_service"
        const val NATIVE_GET_DISCOVERED_DEVICES = "get_discovered_devices"
    }
}