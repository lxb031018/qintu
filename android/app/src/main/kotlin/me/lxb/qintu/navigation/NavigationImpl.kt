package me.lxb.qintu.navigation

import android.content.Context
import android.util.Log
import com.amap.api.maps.model.LatLng
import com.amap.api.navi.AMapNavi
import com.amap.api.navi.AMapNaviListener
import com.amap.api.navi.enums.NaviType
import com.amap.api.navi.enums.TransportType
import com.amap.api.navi.enums.TravelStrategy
import com.amap.api.navi.model.AMapCalcRouteResult
import com.amap.api.navi.model.AMapNaviCameraInfo
import com.amap.api.navi.model.AMapNaviPath
import com.amap.api.navi.model.AMapNaviStep
import com.amap.api.navi.model.AMapTravelInfo
import com.amap.api.navi.model.NaviLatLng
import com.amap.api.navi.model.NaviPoi
import io.flutter.plugin.common.MethodChannel
import me.lxb.qintu.route.RoutePathCache
import me.lxb.qintu.util.AMapPrivacy
import me.lxb.qintu.util.toCoordinateMap

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

        const val STRATEGY_CHEAP = 1
        const val STRATEGY_SHORT = 2
        const val STRATEGY_AVOID_CONGESTION = 3
        const val STRATEGY_CONGESTION_HIGHWAY = 4
        const val STRATEGY_CHEAP_HIGHWAY = 5
        const val STRATEGY_AVOID_HIGHWAY = 6
    }

    private var mAMapNavi: AMapNavi? = null
    private var pendingRouteResult: MethodChannel.Result? = null
    private var isNavigating = false

    /** 导航事件回调（由 Plugin 层注入，用于转发到 EventChannel） */
    var eventListener: ((Map<String, Any?>) -> Unit)? = null

    init {
        AMapPrivacy.initMap(context)

        try {
            mAMapNavi = AMapNavi.getInstance(context)
            mAMapNavi?.addAMapNaviListener(this)
            // 关闭高德导航 SDK 默认的屏幕常亮（文档：默认开启）
            // 导航开始后由 AmapNavigationPlugin 通过 ScreenBrightnessManager 按需激活
            mAMapNavi?.getNaviSetting()?.setScreenAlwaysBright(false)
            Log.d(TAG, "✅ AMapNavi 单例已初始化, setScreenAlwaysBright=false")
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

    private var lastRouteStrategy = 0

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
            lastRouteStrategy = strategy

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
        Log.d(TAG, "📍 NavigationImpl.startNavigation called, isEmulator=$isEmulator, enableVoice=$enableVoice")
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
            mAMapNavi?.let {
                it.stopNavi()
            }
            isNavigating = false
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

    fun resumeNavi(result: MethodChannel.Result) {
        try {
            mAMapNavi?.resumeNavi()
            result.success(true)
        } catch (e: Exception) {
            result.error("RESUME_ERROR", e.message, null)
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
        // strategyConvert(avoidCongestion, avoidCost, prioritiseHighway, prioritiseFastSpeed, multiRoute)
        return when (strategy) {
            STRATEGY_CHEAP               -> navi.strategyConvert(true, true, false, false, multiRoute)
            STRATEGY_SHORT               -> navi.strategyConvert(false, false, false, false, multiRoute)
            STRATEGY_AVOID_CONGESTION    -> navi.strategyConvert(true, false, false, false, multiRoute)
            STRATEGY_CONGESTION_HIGHWAY  -> navi.strategyConvert(true, false, true, false, multiRoute)
            STRATEGY_CHEAP_HIGHWAY       -> navi.strategyConvert(true, true, true, false, multiRoute)
            STRATEGY_AVOID_HIGHWAY       -> navi.strategyConvert(false, false, false, false, multiRoute)
            else                         -> navi.strategyConvert(true, false, false, true, multiRoute)
        }
    }

    private fun serializeNaviPath(routeId: Int, path: AMapNaviPath): Map<String, Any?> {
        val points = path.coordList.map { it.toCoordinateMap() }
        val steps = path.steps?.map { serializePathStep(it) } ?: emptyList()
        return mapOf(
            "routeId" to routeId,
            "distance" to path.allLength.toDouble(),
            "duration" to path.allTime.toDouble(),
            "tolls" to path.tollCost.toDouble(),
            "strategy" to (path.labels ?: ""),
            "trafficLights" to (path.lightList?.size ?: 0),
            "points" to points,
            "steps" to steps
        )
    }

    private fun serializePathStep(step: AMapNaviStep): Map<String, Any?> {
        val coords = step.coords?.map { it.toCoordinateMap() } ?: emptyList()
        val firstCoord = coords.firstOrNull()
        return mapOf(
            "instruction" to "",
            "action" to step.iconType.toString(),
            "road" to "",
            "distance" to step.length.toDouble(),
            "duration" to step.time.toDouble(),
            "tmcStatus" to "",
            "lat" to (firstCoord?.get("lat") ?: 0.0),
            "lng" to (firstCoord?.get("lng") ?: 0.0),
            "points" to coords,
            "startIndex" to step.startIndex,
            "endIndex" to step.endIndex
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
        val calcType = result?.calcRouteType ?: 0
        val routeIds = result?.routeid

        Log.d(TAG, "✅ onCalculateRouteSuccess: calcType=$calcType, routeIds=${routeIds?.contentToString()}")

        val navi = mAMapNavi
        if (navi == null) {
            pendingRouteResult?.error("NAVI_NULL", "AMapNavi 未初始化", null)
            pendingRouteResult = null
            return
        }

        if (routeIds == null || routeIds.isEmpty()) {
            if (calcType == 0) {
                pendingRouteResult?.success(mapOf("routes" to emptyList<Any>()))
                pendingRouteResult = null
            }
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

        Log.d(TAG, "✅ 算路成功：${paths.size} 条路线，calcType=$calcType")

        when (calcType) {
            0 -> {
                // 直接算路（首次算路/用户手动算路）：响应 MethodChannel 请求
                pendingRouteResult?.success(mapOf(
                    "routes" to paths,
                    "strategyId" to lastRouteStrategy
                ))
                pendingRouteResult = null
            }
            1 -> {
                // 偏航重算 → 通知 Flutter 更新路线
                sendEvent("naviStatus", "status" to "recalculated", "reason" to "yaw",
                    "calcRouteType" to calcType, "routes" to paths)
                Log.d(TAG, "📡 偏航重算完成: ${paths.size} 条路线")
            }
            2 -> {
                // 拥堵重算 → 通知 Flutter 更新路线
                sendEvent("naviStatus", "status" to "recalculated", "reason" to "traffic",
                    "calcRouteType" to calcType, "routes" to paths)
                Log.d(TAG, "📡 拥堵重算完成: ${paths.size} 条路线")
            }
            else -> {
                // 其他重算类型（策略变更/平行路切换等）
                val reasonName = when (calcType) {
                    3 -> "strategyChange"
                    4 -> "parallelRoad"
                    else -> "unknown"
                }
                sendEvent("naviStatus", "status" to "recalculated", "reason" to reasonName,
                    "calcRouteType" to calcType, "routes" to paths)
                Log.d(TAG, "📡 其他重算完成: reason=$reasonName, ${paths.size} 条路线")
            }
        }
    }

    override fun onCalculateRouteFailure(result: AMapCalcRouteResult?) {
        val calcType = result?.calcRouteType ?: 0
        val errCode = result?.errorCode ?: -1
        val errDesc = result?.errorDescription ?: "算路失败"

        Log.e(TAG, "❌ onCalculateRouteFailure: calcType=$calcType, code=$errCode, msg=$errDesc")

        if (calcType == 0) {
            // 直接算路失败：响应 MethodChannel 请求
            pendingRouteResult?.error("CALC_FAILED", errDesc, null)
            pendingRouteResult = null
        } else {
            // 重算失败：通过事件通道通知 Flutter
            sendEvent("naviStatus", "status" to "recalcFailed",
                "calcRouteType" to calcType, "errorCode" to errCode, "errorMessage" to errDesc)
            Log.e(TAG, "📡 重算失败: calcType=$calcType, code=$errCode")
        }
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
        isNavigating = true
        sendEvent("naviStatus", "status" to "navigating", "naviType" to type)
    }

    override fun onLocationChange(location: com.amap.api.navi.model.AMapNaviLocation?) {
        location?.let {
            NavigationStateHolder.isMatched = it.isMatchNaviPath
            NavigationStateHolder.naviLocation = it
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
            NavigationStateHolder.pathRetainDistance = it.pathRetainDistance
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
        isNavigating = false
        sendEvent("naviStatus", "status" to "arrived")
    }

    override fun onNaviRouteNotify(routeNotifyData: com.amap.api.navi.model.AMapNaviRouteNotifyData?) {}

    override fun onGpsSignalWeak(isWeak: Boolean) {
        sendEvent("gpsStatus", "isWeak" to isWeak)
    }

    /**
     * 偏航后准备重新规划路线前的通知回调。
     * 仅通知，SDK 内部自动执行重算，开发者无需手动触发算路。
     * 重算成功后 onCalculateRouteSuccess 会被调用（calcRouteType=1）。
     */
    override fun onReCalculateRouteForYaw() {
        Log.d(TAG, "🚨 偏航检测 — SDK 即将自动重算路线（仅通知，SDK 内部处理）")
        sendEvent("naviStatus", "status" to "recalculating", "reason" to "yaw")
    }

    /**
     * 前方遇到拥堵时准备重新规划路线前的通知回调。
     * 仅通知，SDK 内部自动执行重算，开发者无需手动触发算路。
     * 重算成功后 onCalculateRouteSuccess 会被调用（calcRouteType=2）。
     */
    override fun onReCalculateRouteForTrafficJam() {
        Log.d(TAG, "🚦 拥堵检测 — SDK 即将自动重算路线（仅通知，SDK 内部处理）")
        sendEvent("naviStatus", "status" to "recalculating", "reason" to "traffic")
    }

    override fun onArrivedWayPoint(wayPointID: Int) {}

    override fun onGetNavigationText(type: Int, text: String?) {
        sendEvent("naviText", "textType" to type, "text" to (text ?: ""))
    }

    override fun onGetNavigationText(s: String?) {}

    override fun onEndEmulatorNavi() {
        isNavigating = false
        sendEvent("naviStatus", "status" to "stopped")
    }

    override fun onGpsOpenStatus(enabled: Boolean) {}

    override fun updateCameraInfo(cameras: Array<out AMapNaviCameraInfo>?) {
        if (cameras == null || cameras.isEmpty()) return
        val cameraList = cameras.map { camera ->
            mapOf(
                "type" to camera.cameraType,
                "speed" to camera.cameraSpeed,
                "distance" to camera.cameraDistance,
                "lat" to camera.y,
                "lng" to camera.x
            )
        }
        sendEvent("cameraInfo", "cameras" to cameraList)
    }

    override fun updateIntervalCameraInfo(
        cameraInfo: AMapNaviCameraInfo?,
        cameraInfo1: AMapNaviCameraInfo?,
        interval: Int
    ) {
        // 区间测速：cameraInfo=进入点, cameraInfo1=离开点
        val cameras = mutableListOf<Map<String, Any?>>()
        cameraInfo?.let {
            cameras.add(mapOf(
                "type" to it.cameraType,
                "speed" to it.cameraSpeed,
                "distance" to it.cameraDistance,
                "lat" to it.y,
                "lng" to it.x,
                "intervalRemainDistance" to it.intervalRemainDistance,
                "averageSpeed" to it.averageSpeed
            ))
        }
        if (cameras.isNotEmpty()) {
            sendEvent("cameraInterval", "cameras" to cameras)
        }
    }

    override fun onServiceAreaUpdate(serviceAreaInfos: Array<out com.amap.api.navi.model.AMapServiceAreaInfo>?) {}

    override fun showCross(cross: com.amap.api.navi.model.AMapNaviCross?) {}
    override fun hideCross() {}
    override fun showModeCross(cross: com.amap.api.navi.model.AMapModelCross?) {}
    override fun hideModeCross() {}

    override fun showLaneInfo(laneInfos: Array<out com.amap.api.navi.model.AMapLaneInfo>?, laneBackground: ByteArray?, laneRecommended: ByteArray?) {}

    override fun showLaneInfo(laneInfo: com.amap.api.navi.model.AMapLaneInfo?) {}
    override fun hideLaneInfo() {}

    override fun notifyParallelRoad(parallelRoadType: Int) {
        sendEvent("naviStatus", "status" to "parallelRoad", "parallelRoadType" to parallelRoadType)
    }

    override fun updateAimlessModeStatistics(cruiseInfo: com.amap.api.navi.model.AimLessModeStat?) {}

    override fun updateAimlessModeCongestionInfo(congestionInfo: com.amap.api.navi.model.AimLessModeCongestionInfo?) {}

    override fun onPlayRing(ringType: Int) {}
    override fun onTrafficStatusUpdate() {}

    override fun OnUpdateTrafficFacility(trafficFacilityInfo: com.amap.api.navi.model.AMapNaviTrafficFacilityInfo?) {
        trafficFacilityInfo?.let {
            sendEvent("trafficFacility",
                "lat" to it.latitude,
                "lng" to it.longitude,
                "type" to it.type,
                "distance" to it.distance,
                "limitSpeed" to it.limitSpeed
            )
        }
    }

    override fun OnUpdateTrafficFacility(trafficFacilityInfos: Array<out com.amap.api.navi.model.AMapNaviTrafficFacilityInfo>?) {}
}
