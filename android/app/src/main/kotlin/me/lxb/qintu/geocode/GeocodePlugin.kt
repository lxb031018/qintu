package me.lxb.qintu.geocode

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import me.lxb.qintu.constant.PlatformChannels

/**
 * 高德地理编码插件
 *
 * 负责 Flutter ↔ 原生地理编码的通信桥接
 * 委托给功能模块 GeocodeImpl 执行实际地理编码
 */
class GeocodePlugin : FlutterPlugin, MethodCallHandler {

    companion object {
        private const val TAG = "GeocodePlugin"
    }

    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var geocodeImpl: GeocodeImpl? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        channel = MethodChannel(binding.binaryMessenger, PlatformChannels.GEOCODE)
        channel.setMethodCallHandler(this)

        geocodeImpl = GeocodeImpl(binding.applicationContext)

        Log.d(TAG, "地理编码插件已注册")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val impl = geocodeImpl ?: run {
            result.error("NOT_READY", "地理编码模块未初始化", null)
            return
        }

        when (call.method) {
            "regeocode" -> {
                val lat = call.argument<Double>("lat") ?: run {
                    result.error("INVALID_PARAMS", "lat 缺失", null)
                    return
                }
                val lng = call.argument<Double>("lng") ?: run {
                    result.error("INVALID_PARAMS", "lng 缺失", null)
                    return
                }
                impl.regeocode(lat, lng, result)
            }

            "geocodeAddress" -> {
                val address = call.argument<String>("address") ?: run {
                    result.error("INVALID_PARAMS", "address 缺失", null)
                    return
                }
                impl.geocodeAddress(address, result)
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        geocodeImpl = null
        Log.d(TAG, "地理编码插件已分离")
    }
}
