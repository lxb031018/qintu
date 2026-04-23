package me.lxb.qintu

import android.app.Activity
import android.content.Context
import android.util.Log
import com.amap.api.maps.MapsInitializer
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.Poi
import com.amap.api.navi.AmapNaviPage
import com.amap.api.navi.AmapNaviParams
import com.amap.api.navi.AmapNaviType
import com.amap.api.navi.AmapPageType
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * 高德 Android 导航 SDK 桥接插件
 *
 * 使用高德官方导航组件（AmapNaviPage）
 * 参考官方示例：AMap_Android_API_Navi_Demo
 */
class AmapNavigationPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        private const val TAG = "AmapNavigation"
        private const val METHOD_CHANNEL = "com.qintu/amap_navigation"
    }

    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        
        // ✅ 必须：设置高德地图隐私合规（中国法规要求）
        MapsInitializer.updatePrivacyShow(context, true, true)
        MapsInitializer.updatePrivacyAgree(context, true)

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL)
        channel.setMethodCallHandler(this)

        Log.d(TAG, "导航插件已注册")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                result.success(true)
            }

            "startRouteActivity" -> {
                val originName = call.argument<String>("originName")
                val originLat = call.argument<Double>("originLat")
                val originLng = call.argument<Double>("originLng")
                val destinationName = call.argument<String>("destinationName") ?: "终点"
                val destinationLat = call.argument<Double>("destinationLat") ?: 0.0
                val destinationLng = call.argument<Double>("destinationLng") ?: 0.0
                val enableVoice = call.argument<Boolean>("enableVoice") ?: true

                handleStartRouteActivity(
                    originName, originLat, originLng,
                    destinationName, destinationLat, destinationLng,
                    enableVoice, result
                )
            }

            "stopNavigation" -> {
                try {
                    AmapNaviPage.getInstance().exitRouteActivity()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("STOP_ERROR", e.message, null)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * 启动高德官方导航组件（路线规划界面）
     */
    private fun handleStartRouteActivity(
        originName: String?, originLat: Double?, originLng: Double?,
        destinationName: String, destinationLat: Double, destinationLng: Double,
        enableVoice: Boolean, result: Result
    ) {
        try {
            if (destinationLat == 0.0 || destinationLng == 0.0) {
                result.error("INVALID_PARAMS", "终点坐标不能为空", null)
                return
            }

            // 构建起点（为空则使用"我的位置"）
            val start: Poi? = if (originLat != null && originLng != null && originLat != 0.0) {
                Poi(originName ?: "起点", LatLng(originLat, originLng), "")
            } else {
                null
            }

            // 构建终点
            val end = Poi(destinationName, LatLng(destinationLat, destinationLng), "")

            // 构建导航组件参数
            val params = AmapNaviParams(
                start,                            // 起点（null=我的位置）
                null,                             // 途经点列表
                end,                              // 终点
                AmapNaviType.DRIVER,              // 驾车导航
                AmapPageType.ROUTE                // 路线规划界面
            )

            // 配置导航参数
            params.setUseInnerVoice(enableVoice)                     // 使用内部语音播报
            params.setNeedCalculateRouteWhenPresent(true)            // 启动后自动算路
            params.setNeedDestroyDriveManagerInstanceWhenNaviExit(true)

            // 启动官方导航组件
            Log.d(TAG, "启动高德导航组件: ${originName ?: "我的位置"} → $destinationName")

            AmapNaviPage.getInstance().showRouteActivity(context!!, params, null)

            result.success(mapOf(
                "status" to "started",
                "message" to "导航组件已启动"
            ))

        } catch (e: Exception) {
            Log.e(TAG, "启动导航失败", e)
            result.error("START_NAVIGATION_ERROR", e.message, null)
        }
    }

    // ==================== ActivityAware ====================

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d(TAG, "已绑定 Activity")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        Log.d(TAG, "导航插件已分离")
    }
}
