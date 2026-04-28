package me.lxb.qintu

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
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
import io.flutter.plugin.common.EventChannel
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
        private const val EVENT_CHANNEL = "com.qintu/amap_navigation/events"
    }

    private lateinit var channel: MethodChannel
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private var context: Context? = null
    private var activity: Activity? = null
    private var navEventReceiver: BroadcastReceiver? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        // ✅ 必须：设置高德地图隐私合规（中国法规要求）
        MapsInitializer.updatePrivacyShow(context, true, true)
        MapsInitializer.updatePrivacyAgree(context, true)

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL)
        channel.setMethodCallHandler(this)

        // 设置 EventChannel 用于推送导航状态到 Flutter
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL)
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        // 注册导航事件广播接收器
        registerNavigationEventReceiver()

        Log.d(TAG, "导航插件已注册")
    }

    /**
     * 注册导航事件广播接收器，将导航状态转发到 EventChannel
     */
    private fun registerNavigationEventReceiver() {
        navEventReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    NavigationActivity.ACTION_LOCATION_UPDATE -> {
                        val lat = intent.getDoubleExtra("lat", 0.0)
                        val lng = intent.getDoubleExtra("lng", 0.0)
                        val speed = intent.getDoubleExtra("speed", 0.0)
                        val bearing = intent.getDoubleExtra("bearing", 0.0)
                        val accuracy = intent.getDoubleExtra("accuracy", 0.0)
                        val data = mutableMapOf<String, Any?>()
                        data["type"] = "locationUpdate"
                        data["lat"] = lat
                        data["lng"] = lng
                        data["speed"] = speed
                        data["bearing"] = bearing
                        data["accuracy"] = accuracy
                        @Suppress("UNCHECKED_CAST")
                        eventSink?.success(data as Map<String, Any>)
                    }
                    NavigationActivity.ACTION_NAVI_INFO_UPDATE -> {
                        val remainingDistance = intent.getIntExtra("pathRetainDistance", 0)
                        val remainingTime = intent.getIntExtra("pathRetainTime", 0)
                        val nextRoadName = intent.getStringExtra("nextRoadName") ?: ""
                        val currentRoadName = intent.getStringExtra("currentRoadName") ?: ""
                        val data = mutableMapOf<String, Any?>()
                        data["type"] = "naviInfo"
                        data["remainingDistance"] = remainingDistance
                        data["remainingTime"] = remainingTime
                        data["nextRoadName"] = nextRoadName
                        data["currentRoadName"] = currentRoadName
                        @Suppress("UNCHECKED_CAST")
                        eventSink?.success(data as Map<String, Any>)
                    }
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(NavigationActivity.ACTION_LOCATION_UPDATE)
            addAction(NavigationActivity.ACTION_NAVI_INFO_UPDATE)
        }
        context?.let {
            LocalBroadcastManager.getInstance(it).registerReceiver(navEventReceiver!!, filter)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                result.success(true)
            }

            "startNavigation" -> {
                // 启动独立 GPS 导航 Activity（传入路线点）
                // routePoints 格式: List<Map< String, Double>>，每个 Map 包含 latitude 和 longitude
                @Suppress("UNCHECKED_CAST")
                val routePointsList = call.argument<List<Map<String, Double>>>("routePoints") ?: emptyList()
                val enableVoice = call.argument<Boolean>("enableVoice") ?: true
                handleStartNavigation(routePointsList, enableVoice, result)
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
                // 停止导航并关闭 NavigationActivity
                try {
                    val intent = Intent(NavigationActivity.ACTION_STOP_NAVIGATION)
                    context?.let { LocalBroadcastManager.getInstance(it).sendBroadcast(intent) }
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
     * 启动独立 GPS 导航 Activity
     *
     * @param routePoints 路线点列表，每个 Map 包含 latitude 和 longitude
     */
    private fun handleStartNavigation(routePoints: List<Map<String, Double>>, enableVoice: Boolean, result: Result) {
        try {
            val act = activity ?: run {
                result.error("ACTIVITY_NULL", "Activity 为空", null)
                return
            }

            Log.d(TAG, "启动 GPS 导航 Activity，路线点数: ${routePoints.size}")
            Log.d(TAG, "Activity context: ${act.javaClass.name}, hash: ${act.hashCode()}")

            // 将 List<Map> 转换为 JSON 字符串传递给 Activity
            val jsonArray = routePoints.joinToString(",", "[", "]") { point ->
                val lat = point["latitude"] ?: 0.0
                val lng = point["longitude"] ?: 0.0
                "[$lat,$lng]"
            }

            val intent = Intent(act, NavigationActivity::class.java)
            intent.putExtra(NavigationActivity.EXTRA_ROUTE_POINTS, jsonArray)
            intent.putExtra(NavigationActivity.EXTRA_ENABLE_VOICE, enableVoice)
            // 使用 Activity context 启动在同一任务栈中运行
            act.startActivity(intent)
            Log.d(TAG, "startActivity 已调用")

            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "启动 GPS 导航失败", e)
            result.error("START_NAVIGATION_ERROR", e.message, null)
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

            result.success(true)

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
        eventChannel?.setStreamHandler(null)
        // 注销广播接收器
        navEventReceiver?.let {
            context?.let { ctx ->
                LocalBroadcastManager.getInstance(ctx).unregisterReceiver(it)
            }
            navEventReceiver = null
        }
        Log.d(TAG, "导航插件已分离")
    }
}
