package com.anhquan.unisync.utils

import com.anhquan.unisync.models.ChannelResult
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object ChannelUtil {
    private const val authority = "com.anhquan.unisync.channel"
    private var engine: FlutterEngine? = null

    fun setup(engine: FlutterEngine) {
        this.engine = engine
        PairingChannel.setup()
        PreferencesChannel.setup()
    }

    fun destroy() {
        engine = null
        PairingChannel.destroy()
        PreferencesChannel.destroy()
    }

    open class ChannelHandler(private val path: String) {
        inner class ResultEmitter(private val method: String, private val r: MethodChannel.Result) {
            fun emit(resultCode: Int, result: Any? = null, error: String? = null) {
                r.success(toMap(ChannelResult(
                    method = method,
                    resultCode = resultCode,
                    result = result,
                    error = error
                )))
            }

//            fun success(result: Any? = null) {
//                r.success(
//                    toMap(
//                        ChannelResult(
//                            method = method,
//                            resultCode = ChannelResult.SUCCESS,
//                            result = result
//                        )
//                    )
//                )
//            }
//
//            fun error(message: String?) {
//                r.error("", message, null)
//            }
        }

        private var channel: MethodChannel? = null

        private val callHandlers =
            mutableMapOf<String, (Map<String, Any?>?, ResultEmitter) -> Unit>()

        internal fun setup() {
            channel = MethodChannel(engine!!.dartExecutor.binaryMessenger, authority + path)
            channel?.setMethodCallHandler { call, result ->
                if (callHandlers.containsKey(call.method)) {
                    val emitter = ResultEmitter(call.method, result)
                    callHandlers[call.method]!!.invoke(
                        call.arguments as Map<String, Any?>?,
                        emitter
                    )
                } else {
                    errorLog("${this::class.simpleName}@${call.method}: not implemented.")
                }
            }
        }

        internal fun destroy() {
            channel = null
        }

        fun invoke(
            method: String,
            args: Map<String, Any?>? = null,
            onError: (String?) -> Unit = { errorLog("${this::class.simpleName}: error: $it") },
            onResult: ((Any?) -> Unit)? = null,
        ) {
            channel?.invokeMethod(method, args, object : MethodChannel.Result {
                override fun success(result: Any?) {
                    onResult?.invoke(result)
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    onError.invoke("$errorMessage\nDetails: $errorDetails")
                }

                override fun notImplemented() {
                    onError.invoke("${this::class.simpleName}@$method: method not implemented.")
                }
            })
        }

        fun addCallHandler(
            call: String,
            handler: (Map<String, Any?>?, ResultEmitter) -> Unit
        ) {
            callHandlers[call] = handler
            debugLog("${this::class.simpleName}@$call: added handler.")
        }

        fun removeCallHandler(call: String) {
            callHandlers.remove(call)
            debugLog("${this::class.simpleName}@$call: removed handler.")
        }
    }

    object ConnectionChannel : ChannelHandler("/connection") {
        const val GET_CONNECTED_DEVICES = "get_connected_devices"
        const val ADD_DEVICE_MANUALLY = "add_device_manually"

        /**
         * DeviceInfo to JSON:
         * {
         *      "device": {
         *          "id": _id,
         *          "name": _name,
         *          ...
         *      }
         * }
         */
        const val ON_DEVICE_CONNECTED = "on_device_connected"

        /**
         * DeviceInfo to JSON:
         * {
         *      "device": {
         *          "id": _id,
         *          "name": _name,
         *          ...
         *      }
         * }
         */
        const val ON_DEVICE_DISCONNECTED = "on_device_disconnected"
    }

    object PairingChannel : ChannelHandler("/pairing") {
        const val GET_PAIRED_DEVICES = "get_paired_devices"

        /**
         * Param:
         * {
         *      "id": _id
         * }
         */
        const val SET_ACCEPT_PAIR = "set_accept_pair"

        /**
         * Param:
         * {
         *      "id": _id
         * }
         */
        const val SET_REJECT_PAIR = "set_reject_pair"

        /**
         * Param:
         * {
         *      "id": _id,
         * }
         */
        const val ON_DEVICE_PAIR_REQUEST = "on_device_pair_request"

        /**
         * Param:
         * {
         *      "id": _id,
         *      "response": true|false
         * }
         */
        const val ON_DEVICE_PAIR_RESPONSE = "on_device_pair_response"

        const val SEND_PAIR_REQUEST = "send_pair_request"
    }

    object PreferencesChannel : ChannelHandler("/preferences") {
        const val PUT_STRING = "put_string"
        const val PUT_INT = "put_int"
        const val PUT_BOOL = "put_bool"
        const val GET_STRING = "get_string"
        const val GET_INT = "get_int"
        const val GET_BOOL = "get_bool"
    }
}