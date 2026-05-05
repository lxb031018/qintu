package me.lxb.qintu.route

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import me.lxb.qintu.constant.PlatformChannels

/**
 * 高德公交路线搜索插件（Plugin 层）
 *
 * 仅负责 Flutter ↔ 原生公交路线搜索的通信桥接
 * 委托给功能模块 BusRouteSearchImpl 执行实际搜索
 */
class RouteSearchV2Plugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        private const val TAG = "RouteSearchV2"
    }

    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var busRouteSearchImpl: BusRouteSearchImpl? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, PlatformChannels.ROUTE_SEARCH)
        channel.setMethodCallHandler(this)

        Log.d(TAG, "公交路线搜索插件已注册")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "📩 onMethodCall: ${call.method}")

        when (call.method) {
            "calculateBusRoute" -> {
                val fromLat = call.argument<Double>("fromLat")
                val fromLng = call.argument<Double>("fromLng")
                val toLat = call.argument<Double>("toLat")
                val toLng = call.argument<Double>("toLng")
                val city = call.argument<String>("city") ?: ""
                val mode = call.argument<Int>("mode") ?: 0
                val nightFlag = call.argument<Int>("nightFlag") ?: 0

                if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
                    result.error("INVALID_PARAMS", "坐标参数缺失", null)
                    return
                }

                val impl = busRouteSearchImpl
                if (impl == null) {
                    result.error("NOT_READY", "公交路线搜索模块未初始化", null)
                    return
                }

                val routes = impl.calculateBusRoute(
                    fromLat = fromLat,
                    fromLng = fromLng,
                    toLat = toLat,
                    toLng = toLng,
                    city = city,
                    mode = mode,
                    nightFlag = nightFlag
                )
                result.success(routes)
            }

            else -> result.notImplemented()
        }
    }

    // ==================== ActivityAware ====================

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        busRouteSearchImpl = BusRouteSearchImpl(binding.activity)
        Log.d(TAG, "已绑定 Activity，公交路线搜索模块初始化完成")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        busRouteSearchImpl = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        busRouteSearchImpl = BusRouteSearchImpl(binding.activity)
    }

    override fun onDetachedFromActivity() {
        busRouteSearchImpl = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        busRouteSearchImpl = null
        Log.d(TAG, "公交路线搜索插件已分离")
    }
}
