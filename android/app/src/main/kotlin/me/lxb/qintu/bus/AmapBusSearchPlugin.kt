package me.lxb.qintu.bus

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
 * 高德公交搜索插件
 *
 * 负责 Flutter ↔ 原生公交搜索的通信桥接
 * 委托给功能模块 BusSearchImpl 执行实际搜索
 */
class AmapBusSearchPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        private const val TAG = "AmapBusSearch"
    }

    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var busSearchImpl: BusSearchImpl? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, PlatformChannels.BUS_SEARCH)
        channel.setMethodCallHandler(this)

        Log.d(TAG, "公交搜索插件已注册")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val impl = busSearchImpl
        if (impl == null) {
            result.error("NOT_READY", "公交搜索模块未初始化，请确保 Activity 已绑定", null)
            return
        }

        when (call.method) {
            "searchBusStation" -> {
                val keyword = call.argument<String>("keyword") ?: ""
                val city = call.argument<String>("city") ?: ""
                if (keyword.isEmpty()) {
                    result.error("INVALID_PARAMS", "keyword 不能为空", null)
                    return
                }
                impl.searchBusStation(keyword, city, result)
            }

            "searchBusLineByName" -> {
                val keyword = call.argument<String>("keyword") ?: ""
                val city = call.argument<String>("city") ?: ""
                if (keyword.isEmpty()) {
                    result.error("INVALID_PARAMS", "keyword 不能为空", null)
                    return
                }
                impl.searchBusLineByName(keyword, city, result)
            }

            "searchBusLineById" -> {
                val lineId = call.argument<String>("lineId") ?: ""
                val city = call.argument<String>("city") ?: ""
                if (lineId.isEmpty()) {
                    result.error("INVALID_PARAMS", "lineId 不能为空", null)
                    return
                }
                impl.searchBusLineById(lineId, city, result)
            }

            "calculateTransitRoute" -> {
                val fromLat = call.argument<Double>("fromLat") ?: return result.error("INVALID_PARAMS", "fromLat 缺失", null)
                val fromLng = call.argument<Double>("fromLng") ?: return result.error("INVALID_PARAMS", "fromLng 缺失", null)
                val toLat = call.argument<Double>("toLat") ?: return result.error("INVALID_PARAMS", "toLat 缺失", null)
                val toLng = call.argument<Double>("toLng") ?: return result.error("INVALID_PARAMS", "toLng 缺失", null)
                val city = call.argument<String>("city") ?: ""
                val mode = call.argument<Int>("mode") ?: BusSearchImpl.TRANSIT_DEFAULT
                val maxTrans = call.argument<Int>("maxTrans") ?: 3
                val alternativeRoute = call.argument<Int>("alternativeRoute") ?: 1
                val time = call.argument<String>("time")
                val timeType = call.argument<String>("timeType")
                val destCity = call.argument<String>("destCity")
                impl.calculateTransitRoute(fromLat, fromLng, toLat, toLng, city, mode, result,
                    maxTrans, alternativeRoute, time, timeType, destCity)
            }

            else -> result.notImplemented()
        }
    }

    // ==================== ActivityAware ====================

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        busSearchImpl = BusSearchImpl(binding.activity)
        Log.d(TAG, "已绑定 Activity，公交搜索模块初始化完成")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        busSearchImpl?.destroy()
        busSearchImpl = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        busSearchImpl = BusSearchImpl(binding.activity)
    }

    override fun onDetachedFromActivity() {
        busSearchImpl?.destroy()
        busSearchImpl = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        busSearchImpl?.destroy()
        busSearchImpl = null
        Log.d(TAG, "公交搜索插件已分离")
    }
}
