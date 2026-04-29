package me.lxb.qintu

import android.app.Activity
import android.content.Context
import android.util.Log
import com.amap.api.maps.MapsInitializer
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.Poi
import com.amap.api.navi.AMapNavi
import com.amap.api.navi.AMapNaviListener
import com.amap.api.navi.AmapNaviPage
import com.amap.api.navi.AmapNaviParams
import com.amap.api.navi.AmapNaviType
import com.amap.api.navi.AmapPageType
import com.amap.api.navi.model.AMapCalcRouteResult
import com.amap.api.navi.model.AMapNaviPath
import com.amap.api.navi.model.AMapTravelInfo
import com.amap.api.navi.model.NaviLatLng
import com.amap.api.navi.model.NaviPoi
import com.amap.api.navi.enums.NaviType
import com.amap.api.navi.enums.TransportType
import com.amap.api.navi.enums.TravelStrategy
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
class AmapNavigationPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, AMapNaviListener {

    companion object {
        private const val TAG = "AmapNavigation"
        private const val METHOD_CHANNEL = "com.qintu/amap_navigation"
        private const val EVENT_CHANNEL = "com.qintu/amap_navigation/events"

        // 算路策略常量
        const val STRATEGY_FAST = 0        // 高速优先 + 躲避拥堵
        const val STRATEGY_CHEAP = 1       // 避免收费 + 躲避拥堵
        const val STRATEGY_SHORT = 2       // 距离最短 + 躲避拥堵
    }

    private lateinit var channel: MethodChannel
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private var context: Context? = null
    private var activity: Activity? = null
    private var mAMapNavi: AMapNavi? = null
    private var pendingRouteResult: MethodChannel.Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        // ✅ 必须：设置高德地图隐私合规（中国法规要求）
        MapsInitializer.updatePrivacyShow(context, true, true)
        MapsInitializer.updatePrivacyAgree(context, true)

        // 初始化导航 SDK 单例
        try {
            mAMapNavi = AMapNavi.getInstance(context!!)
            mAMapNavi?.addAMapNaviListener(this)
            Log.d(TAG, "✅ AMapNavi 单例已初始化并注册监听")
        } catch (e: Exception) {
            Log.e(TAG, "❌ AMapNavi 初始化失败: ${e.message}")
        }

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

        Log.d(TAG, "导航插件已注册")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                result.success(true)
            }

            "calculateRoute" -> handleCalculateRoute(call, result)

            "selectRouteId" -> {
                val routeId = call.argument<Int>("routeId") ?: 0
                mAMapNavi?.selectRouteId(routeId)
                result.success(true)
            }

            "startNavigation" -> {
                val isEmulator = call.argument<Boolean>("isEmulator") ?: false
                val enableVoice = call.argument<Boolean>("enableVoice") ?: true
                handleStartHeadlessNavigation(isEmulator, enableVoice, result)
            }

            "stopNavigation" -> {
                try {
                    mAMapNavi?.stopNavi()
                    sendNavEvent("naviStatus", "status" to "stopped")
                    result.success(true)
                } catch (e: Exception) {
                    result.error("STOP_ERROR", e.message, null)
                }
            }

            "togglePause" -> {
                try {
                    mAMapNavi?.pauseNavi()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("PAUSE_ERROR", e.message, null)
                }
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

            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * 通过导航 SDK 计算路线（驾车/步行/骑行）
     *
     * 策略映射:
     *   strategy=0 → 高速优先 + 躲避拥堵
     *   strategy=1 → 避免收费 + 躲避拥堵
     *   strategy=2 → 距离最短 + 躲避拥堵
     */
    private fun handleCalculateRoute(call: MethodCall, result: Result) {
        try {
            val navi = mAMapNavi
            if (navi == null) {
                result.error("NAVI_NULL", "AMapNavi 未初始化", null)
                return
            }

            val routeType = call.argument<String>("routeType") ?: "driving"
            val fromLat = call.argument<Double>("fromLat") ?: return result.error("INVALID_PARAMS", "fromLat 缺失", null)
            val fromLng = call.argument<Double>("fromLng") ?: return result.error("INVALID_PARAMS", "fromLng 缺失", null)
            val toLat = call.argument<Double>("toLat") ?: return result.error("INVALID_PARAMS", "toLat 缺失", null)
            val toLng = call.argument<Double>("toLng") ?: return result.error("INVALID_PARAMS", "toLng 缺失", null)
            val strategy = call.argument<Int>("strategy") ?: 0
            val multiRoute = call.argument<Boolean>("multiRoute") ?: true

            // 防止并发算路：取消上一个未完成的请求
            pendingRouteResult?.let {
                Log.w(TAG, "⚠️ 覆盖上一个未完成的算路请求")
                it.error("CALC_OVERRIDDEN", "被新的算路请求覆盖", null)
            }
            pendingRouteResult = result

            val from = NaviLatLng(fromLat, fromLng)
            val to = NaviLatLng(toLat, toLng)

            Log.d(TAG, "🗺️ 开始算路: type=$routeType, from=($fromLat,$fromLng), to=($toLat,$toLng), strategy=$strategy, multiRoute=$multiRoute")

            when (routeType) {
                "driving" -> {
                    val flag = buildDrivingStrategy(strategy, multiRoute)
                    navi.calculateDriveRoute(listOf(from), listOf(to), null, flag)
                }
                "walking" -> {
                    val fromPoi = NaviPoi("起点", LatLng(fromLat, fromLng), "")
                    val toPoi = NaviPoi("终点", LatLng(toLat, toLng), "")
                    val ts = if (multiRoute) TravelStrategy.MULTIPLE else TravelStrategy.SINGLE
                    navi.setTravelInfo(AMapTravelInfo(TransportType.Walk))
                    navi.calculateWalkRoute(fromPoi, toPoi, ts)
                }
                "riding" -> {
                    val fromPoi = NaviPoi("起点", LatLng(fromLat, fromLng), "")
                    val toPoi = NaviPoi("终点", LatLng(toLat, toLng), "")
                    val ts = if (multiRoute) TravelStrategy.MULTIPLE else TravelStrategy.SINGLE
                    navi.setTravelInfo(AMapTravelInfo(TransportType.Ride))
                    navi.calculateRideRoute(fromPoi, toPoi, ts)
                }
                else -> {
                    pendingRouteResult = null
                    result.error("INVALID_TYPE", "不支持的出行方式: $routeType", null)
                }
            }
        } catch (e: Exception) {
            pendingRouteResult = null
            Log.e(TAG, "❌ 算路异常: ${e.message}")
            result.error("CALC_ERROR", e.message, null)
        }
    }

    /**
     * 构建驾车策略标志
     * strategyConvert(躲避拥堵, 避免收费, 不走高速, 高速优先, 多路径)
     */
    private fun buildDrivingStrategy(strategy: Int, multiRoute: Boolean): Int {
        val navi = mAMapNavi ?: return 0
        return when (strategy) {
            STRATEGY_CHEAP  -> navi.strategyConvert(true, true, false, false, multiRoute)
            STRATEGY_SHORT  -> navi.strategyConvert(true, false, false, false, multiRoute)
            else            -> navi.strategyConvert(true, false, false, true, multiRoute)
        }
    }

    /**
     * 将 AMapNaviPath 序列化为 Map 返回 Flutter
     * 只序列化 SDK 已证实可用的字段
     */
    private fun serializeNaviPath(path: AMapNaviPath): Map<String, Any?> {
        val points = path.coordList.map {
            mapOf("lat" to it.latitude, "lng" to it.longitude)
        }

        // AMapNaviStep 的字段名在不同 SDK 版本中不稳定，暂时只返回坐标
        // 导航步骤详情由后续调用 getNaviPath().getSteps() 时再适配
        val steps = emptyList<Map<String, Any?>>()

        return mapOf(
            "distance" to path.allLength.toDouble(),
            "duration" to path.allTime.toDouble(),
            "tolls" to 0.0,
            "strategy" to (path.labels ?: ""),
            "trafficLights" to 0,
            "points" to points,
            "steps" to steps
        )
    }

    // ==================== AMapNaviListener (仅处理算路回调) ====================

    override fun onCalculateRouteSuccess(result: AMapCalcRouteResult?) {
        Log.d(TAG, "✅ onCalculateRouteSuccess: routeIds=${result?.routeid?.contentToString()}")

        val navi = mAMapNavi
        if (navi == null) {
            pendingRouteResult?.error("NAVI_NULL", "AMapNavi 未初始化", null)
            pendingRouteResult = null
            return
        }

        val routeIds = result?.routeid
        if (routeIds == null || routeIds.isEmpty()) {
            pendingRouteResult?.success(mapOf("routes" to emptyList<Any>()))
            pendingRouteResult = null
            return
        }

        val allPaths = navi.naviPaths  // HashMap<Int, AMapNaviPath>
        val paths = mutableListOf<Map<String, Any?>>()
        for (routeId in routeIds) {
            val path = allPaths[routeId]
            if (path != null) {
                paths.add(serializeNaviPath(path))
            }
        }

        Log.d(TAG, "✅ 算路成功: ${paths.size} 条路线")
        pendingRouteResult?.success(mapOf("routes" to paths))
        pendingRouteResult = null
    }

    override fun onCalculateRouteFailure(result: AMapCalcRouteResult?) {
        Log.e(TAG, "❌ onCalculateRouteFailure: code=${result?.errorCode}, msg=${result?.errorDescription}")
        pendingRouteResult?.error(
            "CALC_FAILED",
            result?.errorDescription ?: "算路失败",
            null
        )
        pendingRouteResult = null
    }

    // 旧版抽象接口（必须实现）
    override fun onCalculateRouteSuccess(ints: IntArray?) {}
    override fun onCalculateRouteFailure(errorCode: Int) {}

    // 以下 AMapNaviListener 回调 — 将导航事件转发到 Flutter EventChannel
    override fun onInitNaviSuccess() {
        Log.d(TAG, "✅ 导航引擎初始化成功")
        sendNavEvent("naviStatus", "status" to "ready")
    }
    override fun onInitNaviFailure() {
        Log.e(TAG, "❌ 导航引擎初始化失败")
        sendNavEvent("naviStatus", "status" to "error", "error" to "导航引擎初始化失败")
    }
    override fun onStartNavi(type: Int) {
        Log.d(TAG, "🚗 导航已启动 type=$type")
        sendNavEvent("naviStatus", "status" to "navigating", "naviType" to type)
    }
    override fun onLocationChange(location: com.amap.api.navi.model.AMapNaviLocation?) {
        location?.let {
            val coord = it.coord
            sendNavEvent("locationUpdate",
                "lat" to coord.latitude,
                "lng" to coord.longitude,
                "speed" to it.speed.toDouble(),
                "bearing" to it.bearing.toDouble(),
                "accuracy" to it.accuracy.toDouble()
            )
        }
    }
    override fun onNaviInfoUpdate(naviInfo: com.amap.api.navi.model.NaviInfo?) {
        naviInfo?.let {
            val next = it.nextRoadName ?: ""
            val cur = it.currentRoadName ?: ""
            sendNavEvent("naviInfo",
                "remainingDistance" to it.pathRetainDistance,
                "remainingTime" to it.pathRetainTime,
                "nextRoadName" to next,
                "currentRoadName" to cur,
                "iconType" to it.iconType
            )
        }
    }
    override fun onArriveDestination() {
        Log.d(TAG, "🏁 已到达目的地")
        sendNavEvent("naviStatus", "status" to "arrived")
    }
    override fun onNaviRouteNotify(routeNotifyData: com.amap.api.navi.model.AMapNaviRouteNotifyData?) {}
    override fun onGpsSignalWeak(isWeak: Boolean) {
        sendNavEvent("gpsStatus", "isWeak" to isWeak)
    }
    override fun onReCalculateRouteForYaw() {
        Log.d(TAG, "🚨 偏航，重新算路")
        sendNavEvent("naviStatus", "status" to "recalculating", "reason" to "yaw")
    }
    override fun onReCalculateRouteForTrafficJam() {
        Log.d(TAG, "🚦 拥堵，重新算路")
        sendNavEvent("naviStatus", "status" to "recalculating", "reason" to "traffic")
    }
    override fun onArrivedWayPoint(wayPointID: Int) {}
    override fun onGetNavigationText(type: Int, text: String?) {
        sendNavEvent("naviText", "textType" to type, "text" to (text ?: ""))
    }
    override fun onGetNavigationText(s: String?) {}
    override fun onEndEmulatorNavi() {
        sendNavEvent("naviStatus", "status" to "stopped")
    }
    override fun onGpsOpenStatus(enabled: Boolean) {}
    override fun updateCameraInfo(cameras: Array<out com.amap.api.navi.model.AMapNaviCameraInfo>?) {}
    override fun updateIntervalCameraInfo(cameraInfo: com.amap.api.navi.model.AMapNaviCameraInfo?, cameraInfo1: com.amap.api.navi.model.AMapNaviCameraInfo?, interval: Int) {}
    override fun onServiceAreaUpdate(serviceAreaInfos: Array<out com.amap.api.navi.model.AMapServiceAreaInfo>?) {}
    override fun showCross(cross: com.amap.api.navi.model.AMapNaviCross?) {}
    override fun hideCross() {}
    override fun showModeCross(cross: com.amap.api.navi.model.AMapModelCross?) {}
    override fun hideModeCross() {}
    override fun showLaneInfo(laneInfos: Array<out com.amap.api.navi.model.AMapLaneInfo>?, laneBackground: ByteArray?, laneRecommended: ByteArray?) {}
    override fun showLaneInfo(laneInfo: com.amap.api.navi.model.AMapLaneInfo?) {}
    override fun hideLaneInfo() {}
    override fun notifyParallelRoad(parallelRoadType: Int) {}
    override fun updateAimlessModeStatistics(cruiseInfo: com.amap.api.navi.model.AimLessModeStat?) {}
    override fun updateAimlessModeCongestionInfo(congestionInfo: com.amap.api.navi.model.AimLessModeCongestionInfo?) {}
    override fun onPlayRing(ringType: Int) {}
    override fun onTrafficStatusUpdate() {}
    override fun OnUpdateTrafficFacility(trafficFacilityInfo: com.amap.api.navi.model.AMapNaviTrafficFacilityInfo?) {}
    override fun OnUpdateTrafficFacility(trafficFacilityInfos: Array<out com.amap.api.navi.model.AMapNaviTrafficFacilityInfo>?) {}

    // ==================== 辅助方法 ====================

    private fun sendNavEvent(type: String, vararg pairs: Pair<String, Any?>) {
        val data = mutableMapOf<String, Any?>("type" to type)
        pairs.forEach { data[it.first] = it.second }
        @Suppress("UNCHECKED_CAST")
        eventSink?.success(data as Map<String, Any>)
    }

    private fun handleStartHeadlessNavigation(isEmulator: Boolean, enableVoice: Boolean, result: Result) {
        try {
            val navi = mAMapNavi ?: run {
                result.error("NAVI_NULL", "AMapNavi 未初始化", null)
                return
            }

            navi.setUseInnerVoice(enableVoice)
            val naviType = if (isEmulator) NaviType.EMULATOR else NaviType.GPS
            if (isEmulator) {
                navi.setEmulatorNaviSpeed(60)
            }

            val ret = navi.startNavi(naviType)
            Log.d(TAG, "🗺️ 启动无View导航: type=$naviType, result=$ret")
            result.success(ret)
        } catch (e: Exception) {
            Log.e(TAG, "❌ 启动导航失败", e)
            result.error("START_NAVI_ERROR", e.message, null)
        }
    }

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

            val start: Poi? = if (originLat != null && originLng != null && originLat != 0.0) {
                Poi(originName ?: "起点", LatLng(originLat, originLng), "")
            } else {
                null
            }

            val end = Poi(destinationName, LatLng(destinationLat, destinationLng), "")

            val params = AmapNaviParams(
                start,
                null,
                end,
                AmapNaviType.DRIVER,
                AmapPageType.ROUTE
            )

            params.setUseInnerVoice(enableVoice)
            params.setNeedCalculateRouteWhenPresent(true)
            params.setNeedDestroyDriveManagerInstanceWhenNaviExit(true)

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
        mAMapNavi?.removeAMapNaviListener(this)
        mAMapNavi = null
        Log.d(TAG, "导航插件已分离")
    }
}
