package me.lxb.qintu.poi

import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import me.lxb.qintu.constant.PlatformChannels

/**
 * 高德 POI 搜索插件
 *
 * 负责 Flutter ↔ 原生 POI 搜索的通信桥接
 * 委托给功能模块 PoiSearchImpl 执行实际搜索
 */
class PoiSearchPlugin : FlutterPlugin, MethodCallHandler {

    companion object {
        private const val TAG = "PoiSearchPlugin"
    }

    private lateinit var channel: MethodChannel
    private var poiSearchImpl: PoiSearchImpl? = null
    private var inputtipsImpl: InputtipsImpl? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, PlatformChannels.POI_SEARCH)
        channel.setMethodCallHandler(this)

        poiSearchImpl = PoiSearchImpl(binding.applicationContext)
        inputtipsImpl = InputtipsImpl(binding.applicationContext)

        Log.d(TAG, "POI搜索插件已注册")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val impl = poiSearchImpl ?: run {
            result.error("NOT_READY", "POI搜索模块未初始化", null)
            return
        }

        when (call.method) {
            "searchPoi" -> {
                val keyword = call.argument<String>("keyword") ?: run {
                    result.error("INVALID_PARAMS", "keyword 缺失", null)
                    return
                }
                val city = call.argument<String>("city")
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val radius = call.argument<Int>("radius") ?: 50000
                val cityLimit = call.argument<Boolean>("cityLimit") ?: false

                impl.searchPoi(keyword, city, lat, lng, radius, cityLimit, result)
            }

            "inputTips" -> {
                val keyword = call.argument<String>("keyword") ?: run {
                    result.error("INVALID_PARAMS", "keyword 缺失", null)
                    return
                }
                val city = call.argument<String>("city")
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")

                val tips = inputtipsImpl ?: run {
                    result.error("NOT_READY", "输入提示模块未初始化", null)
                    return
                }
                tips.searchInputtips(keyword, city, lat, lng, result)
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        poiSearchImpl?.destroy()
        poiSearchImpl = null
        inputtipsImpl?.destroy()
        inputtipsImpl = null
        Log.d(TAG, "POI搜索插件已分离")
    }
}
