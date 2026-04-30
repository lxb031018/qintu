package me.lxb.qintu.navigation

import android.content.Context
import android.util.Log
import com.amap.api.maps.MapsInitializer
import com.amap.api.maps.model.LatLng
import com.amap.api.navi.AMapNavi
import com.amap.api.navi.AMapNaviListener
import com.amap.api.navi.enums.NaviType
import com.amap.api.navi.enums.TransportType
import com.amap.api.navi.enums.TravelStrategy
import com.amap.api.navi.model.AMapCalcRouteResult
import com.amap.api.navi.model.AMapNaviPath
import com.amap.api.navi.model.AMapTravelInfo
import com.amap.api.navi.model.NaviLatLng
import com.amap.api.navi.model.NaviPoi
import io.flutter.plugin.common.MethodChannel
import me.lxb.qintu.route.RoutePathCache

/**
 * 导航功能模块
 *
 * 封装高德导航 SDK (AMapNavi) 的全部能力：
 * - 驾车/步行/骑行算路
 * - 多路线管理
 * - 导航启停控制
 * - 导航事件回调
 */
class NavigationImpl(context: Context) : AMapNaviListener {

    companion object {
        private const val TAG = "NavigationImpl"

        const val STRATEGY_FAST = 0
        const val STRATEGY_CHEAP = 1
        const val STRATEGY_SHORT = 2
    }

    private var mAMapNavi: AMapNavi? = null
    private var pendingRouteResult: MethodChannel.Result? = null

    /** 导航事件回调（由 Plugin 层注入，用于转发到 EventChannel） */
    var eventListener: ((Map<String, Any?>) -> Unit)? = null

    init {
        MapsInitializer.updatePrivacyShow(context, true, true)
        MapsInitializer.updatePrivacyAgree(context, true)

        try {
            mAMapNavi = AMapNavi.getInstance(context)
            mAMapNavi?.addAMapNaviListener(this)
            Log.d(TAG, "✅ AMapNavi 单例已初始化并注册监听")
        } catch (e: Exception) {
            Log.e(TAG, "❌ AMapNavi 初始化失败：${e.message}")
        }
    }

    // ==================== 公开接口 ====================

    fun initialize(result: MethodChannel.Result) {
        result.success(true)
    }

    fun selectRouteId(routeId: Int) {
        mAMapNavi?.selectRouteId(routeId)
    }

    fun calculateRoute(
        routeType: String,
        fromLat: Double, fromLng: Double,
        toLat: Double, toLng: Double,
        strategy: Int, multiRoute: Boolean,
        result: MethodChannel.Result
    ) {
        try {
            val navi = mAMapNavi
            if (navi == null) {
                result.error("NAVI_NULL", "AMapNavi 未初始化", null)
                return
            }

            // 防止并发算路：取消上一个未完成的请求
            pendingRouteResult?.let {
                Log.w(TAG, "⚠️ 覆盖上一个未完成的算路请求")
                it.error("CALC_OVERRIDDEN", "被新的算路请求覆盖", null)
            }
            pendingRouteResult = result

            val from = NaviLatLng(fromLat, fromLng)
            val to = NaviLatLng(toLat, toLng)

            Log.d(TAG, "🗺️ 开始算路：type=$routeType, from=($fromLat,$fromLng), to=($toLat,$toLng), strategy=$strategy, multiRoute=$multiRoute")

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
                    result.error("INVALID_TYPE", "不支持的出行方式：$routeType", null)
                }
            }
        } catch (e: Exception) {
            pendingRouteResult = null
            Log.e(TAG, "❌ 算路异常：${e.message}")
            result.error("CALC_ERROR", e.message, null)
        }
    }

    fun startNavigation(isEmulator: Boolean, enableVoice: Boolean, result: MethodChannel.Result) {
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
            Log.d(TAG, "🗺️ 启动无 View 导航：type=$naviType, result=$ret")
            result.success(ret)
        } catch (e: Exception) {
            Log.e(TAG, "❌ 启动导航失败", e)
            result.error("START_NAVI_ERROR", e.message, null)
        }
    }

    fun stopNavi(result: MethodChannel.Result) {
        try {
            mAMapNavi?.stopNavi()
            sendEvent("naviStatus", "status" to "stopped")
            result.success(true)
        } catch (e: Exception) {
            result.error("STOP_ERROR", e.message, null)
        }
    }

    fun pauseNavi(result: MethodChannel.Result) {
        try {
            mAMapNavi?.pauseNavi()
            result.success(true)
        } catch (e: Exception) {
            result.error("PAUSE_ERROR", e.message, null)
        }
    }

    fun destroy() {
        mAMapNavi?.removeAMapNaviListener(this)
        mAMapNavi = null
        pendingRouteResult = null
        eventListener = null
    }

    // ==================== 私有方法 ====================

    private fun buildDrivingStrategy(strategy: Int, multiRoute: Boolean): Int {
        val navi = mAMapNavi ?: return 0
        return when (strategy) {
            STRATEGY_CHEAP  -> navi.strategyConvert(true, true, false, false, multiRoute)
            STRATEGY_SHORT  -> navi.strategyConvert(true, false, false, false, multiRoute)
            else            -> navi.strategyConvert(true, false, false, true, multiRoute)
        }
    }

    private fun serializeNaviPath(routeId: Int, path: AMapNaviPath): Map<String, Any?> {
        val points = path.coordList.map {
            mapOf("lat" to it.latitude, "lng" to it.longitude)
        }
        return mapOf(
            "routeId" to routeId,
            "distance" to path.allLength.toDouble(),
            "duration" to path.allTime.toDouble(),
            "tolls" to 0.0,
            "strategy" to (path.labels ?: ""),
            "trafficLights" to 0,
            "points" to points,
            "steps" to emptyList<Map<String, Any?>>()
        )
    }

    private fun sendEvent(type: String, vararg pairs: Pair<String, Any?>) {
        val data = mutableMapOf<String, Any?>("type" to type)
        pairs.forEach { data[it.first] = it.second }
        @Suppress("UNCHECKED_CAST")
        eventListener?.invoke(data as Map<String, Any>)
    }

    // ==================== AMapNaviListener ====================

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

        val allPaths = navi.naviPaths

        RoutePathCache.clear()
        RoutePathCache.putAll(allPaths)

        val paths = mutableListOf<Map<String, Any?>>()
        for (routeId in routeIds) {
            val path = allPaths[routeId]
            if (path != null) {
                paths.add(serializeNaviPath(routeId, path))
            }
        }

        Log.d(TAG, "✅ 算路成功：${paths.size} 条路线，已缓存到 RoutePathCache")
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

    override fun onInitNaviSuccess() {
        Log.d(TAG, "✅ 导航引擎初始化成功")
        sendEvent("naviStatus", "status" to "ready")
    }

    override fun onInitNaviFailure() {
        Log.e(TAG, "❌ 导航引擎初始化失败")
        sendEvent("naviStatus", "status" to "error", "error" to "导航引擎初始化失败")
    }

    override fun onStartNavi(type: Int) {
        Log.d(TAG, "🚗 导航已启动 type=$type")
        sendEvent("naviStatus", "status" to "navigating", "naviType" to type)
    }

    override fun onLocationChange(location: com.amap.api.navi.model.AMapNaviLocation?) {
        location?.let {
            val coord = it.coord
            sendEvent("locationUpdate",
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
            sendEvent("naviInfo",
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
        sendEvent("naviStatus", "status" to "arrived")
    }

    override fun onNaviRouteNotify(routeNotifyData: com.amap.api.navi.model.AMapNaviRouteNotifyData?) {}

    override fun onGpsSignalWeak(isWeak: Boolean) {
        sendEvent("gpsStatus", "isWeak" to isWeak)
    }

    override fun onReCalculateRouteForYaw() {
        Log.d(TAG, "🚨 偏航，重新算路")
        sendEvent("naviStatus", "status" to "recalculating", "reason" to "yaw")
    }

    override fun onReCalculateRouteForTrafficJam() {
        Log.d(TAG, "🚦 拥堵，重新算路")
        sendEvent("naviStatus", "status" to "recalculating", "reason" to "traffic")
    }

    override fun onArrivedWayPoint(wayPointID: Int) {}

    override fun onGetNavigationText(type: Int, text: String?) {
        sendEvent("naviText", "textType" to type, "text" to (text ?: ""))
    }

    override fun onGetNavigationText(s: String?) {}

    override fun onEndEmulatorNavi() {
        sendEvent("naviStatus", "status" to "stopped")
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
}
