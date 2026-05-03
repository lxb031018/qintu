package me.lxb.qintu.route

import android.content.Context
import android.util.Log
import com.amap.api.services.core.AMapException
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.route.BusPathV2
import com.amap.api.services.route.BusRouteResultV2
import com.amap.api.services.route.BusStepV2
import com.amap.api.services.route.DrivePathV2
import com.amap.api.services.route.DriveRouteResultV2
import com.amap.api.services.route.DriveStepV2
import com.amap.api.services.route.RidePath
import com.amap.api.services.route.RideRouteResultV2
import com.amap.api.services.route.RideStep
import com.amap.api.services.route.RouteBusLineItem
import com.amap.api.services.route.RouteSearch
import com.amap.api.services.route.RouteSearchV2
import com.amap.api.services.route.TruckPath
import com.amap.api.services.route.TruckRouteRestult
import com.amap.api.services.route.TruckStep
import com.amap.api.services.route.WalkPath
import com.amap.api.services.route.WalkRouteResultV2
import com.amap.api.services.route.WalkStep
import me.lxb.qintu.util.AMapPrivacy
import me.lxb.qintu.util.toCoordinateMap
import java.text.SimpleDateFormat
import java.util.Locale

/**
 * 路径搜索功能模块（基于 RouteSearchV2）
 *
 * 封装高德搜索 SDK RouteSearchV2 的全部能力：
 * - 驾车/步行/骑行/公交路径规划（V2）
 * - 货车路径规划（旧 RouteSearch——V2 无货车 API）
 * - 多路线管理、全字段序列化（含 TMC 路况、Cost、限行等）
 */
class RouteSearchImpl(private val context: Context) {

    companion object {
        private const val TAG = "RouteSearchImpl"
        private const val DATE_FORMAT = "HHmm"

        fun drivingStrategyFromInt(value: Int): RouteSearchV2.DrivingStrategy = when (value) {
            // 单路径策略 (0-9) - 已废弃，仅作兼容映射
            0 -> RouteSearchV2.DrivingStrategy.DEFAULT
            1 -> RouteSearchV2.DrivingStrategy.LESS_CHARGE
            2 -> RouteSearchV2.DrivingStrategy.SPEED_PRIORITY
            3 -> RouteSearchV2.DrivingStrategy.AVOID_CONGESTION
            4 -> RouteSearchV2.DrivingStrategy.AVOID_CONGESTION_HIGHWAY_PRIORITY
            5 -> RouteSearchV2.DrivingStrategy.LESS_CHARGE_AVOID_HIGHWAY
            6 -> RouteSearchV2.DrivingStrategy.AVOID_HIGHWAY
            // 多路径策略 (10-20) - 推荐使用
            10 -> RouteSearchV2.DrivingStrategy.DEFAULT
            11 -> RouteSearchV2.DrivingStrategy.SPEED_PRIORITY
            12 -> RouteSearchV2.DrivingStrategy.AVOID_CONGESTION
            13 -> RouteSearchV2.DrivingStrategy.AVOID_HIGHWAY
            14 -> RouteSearchV2.DrivingStrategy.LESS_CHARGE
            15 -> RouteSearchV2.DrivingStrategy.AVOID_CONGESTION_HIGHWAY_PRIORITY
            16 -> RouteSearchV2.DrivingStrategy.LESS_CHARGE_AVOID_HIGHWAY
            17 -> RouteSearchV2.DrivingStrategy.AVOID_CONGESTION
            18 -> RouteSearchV2.DrivingStrategy.AVOID_CONGESTION_HIGHWAY_PRIORITY
            19 -> RouteSearchV2.DrivingStrategy.SPEED_PRIORITY
            20 -> RouteSearchV2.DrivingStrategy.AVOID_CONGESTION_HIGHWAY_PRIORITY
            else -> RouteSearchV2.DrivingStrategy.DEFAULT
        }
    }

    private var driveCallback: ((Map<String, Any?>?, String?) -> Unit)? = null
    private var walkCallback: ((Map<String, Any?>?, String?) -> Unit)? = null
    private var rideCallback: ((Map<String, Any?>?, String?) -> Unit)? = null
    private var busCallback: ((Map<String, Any?>?, String?) -> Unit)? = null
    private var truckCallback: ((Map<String, Any?>?, String?) -> Unit)? = null

    private var busOrigin: LatLonPoint? = null
    private var busDest: LatLonPoint? = null

    private val routeSearchV2: RouteSearchV2
    private val routeSearchV1: RouteSearch = RouteSearch(context)

    init {
        AMapPrivacy.initSearch(context)

        routeSearchV2 = try {
            RouteSearchV2(context)
        } catch (e: AMapException) {
            Log.e(TAG, "❌ RouteSearchV2 初始化失败：${e.message}")
            throw e
        }

        routeSearchV2.setRouteSearchListener(object : RouteSearchV2.OnRouteSearchListener {
            override fun onDriveRouteSearched(result: DriveRouteResultV2?, errorCode: Int) {
                val cb = driveCallback; driveCallback = null
                if (cb == null) { Log.w(TAG, "⚠️ 未找到驾车算路回调"); return }
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val paths = result.paths.mapIndexed { i, p -> serializeDrivePathV2(i, p) }
                    cb(mapOf("paths" to paths, "taxiCost" to result.taxiCost.toDouble()), null)
                } else {
                    cb(null, "驾车算路失败: $errorCode")
                }
            }

            override fun onWalkRouteSearched(result: WalkRouteResultV2?, errorCode: Int) {
                val cb = walkCallback; walkCallback = null
                if (cb == null) { Log.w(TAG, "⚠️ 未找到步行算路回调"); return }
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val paths = result.paths.mapIndexed { i, p -> serializeWalkPath(i, p) }
                    cb(mapOf("paths" to paths), null)
                } else {
                    cb(null, "步行算路失败: $errorCode")
                }
            }

            override fun onRideRouteSearched(result: RideRouteResultV2?, errorCode: Int) {
                val cb = rideCallback; rideCallback = null
                if (cb == null) { Log.w(TAG, "⚠️ 未找到骑行算路回调"); return }
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val paths = result.paths.mapIndexed { i, p -> serializeRidePath(i, p) }
                    cb(mapOf("paths" to paths), null)
                } else {
                    cb(null, "骑行算路失败: $errorCode")
                }
            }

            override fun onBusRouteSearched(result: BusRouteResultV2?, errorCode: Int) {
                val cb = busCallback; busCallback = null
                val origin = busOrigin; val dest = busDest
                busOrigin = null; busDest = null
                if (cb == null) { Log.w(TAG, "⚠️ 未找到公交算路回调"); return }
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val paths = result.paths.map { serializeBusPathV2(it, origin, dest) }
                    cb(mapOf("paths" to paths, "taxiCost" to result.taxiCost.toDouble()), null)
                } else {
                    cb(null, "公交算路失败: $errorCode")
                }
            }
        })

        routeSearchV1.setOnTruckRouteSearchListener(object : RouteSearch.OnTruckRouteSearchListener {
            override fun onTruckRouteSearched(result: TruckRouteRestult?, errorCode: Int) {
                val cb = truckCallback; truckCallback = null
                if (cb == null) { Log.w(TAG, "⚠️ 未找到货车算路回调"); return }
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val paths = result.paths.mapIndexed { i, p -> serializeTruckPath(i, p) }
                    cb(mapOf("paths" to paths), null)
                } else {
                    cb(null, "货车算路失败: $errorCode")
                }
            }
        })
    }

    // ==================== 公开接口 ====================

    fun calculateDriveRoute(
        fromLat: Double, fromLng: Double,
        toLat: Double, toLng: Double,
        strategy: Int,
        callback: (Map<String, Any?>?, String?) -> Unit,
        alternativeRoute: Int = 1,
        carType: Int = 0,
        passedPoints: List<LatLonPoint>? = null,
        avoidRoad: String? = null
    ) {
        Log.d(TAG, "🚗 驾车算路: ($fromLat,$fromLng) → ($toLat,$toLng), strategy=$strategy, carType=$carType")
        driveCallback = callback

        val fromAndTo = RouteSearchV2.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )

        val mode = drivingStrategyFromInt(strategy)
        val query = RouteSearchV2.DriveRouteQuery(fromAndTo, mode, passedPoints, null, avoidRoad ?: "")
        query.carType = carType
        query.showFields = RouteSearchV2.ShowFields.ALL

        routeSearchV2.calculateDriveRouteAsyn(query)
    }

    fun calculateWalkRoute(
        fromLat: Double, fromLng: Double,
        toLat: Double, toLng: Double,
        callback: (Map<String, Any?>?, String?) -> Unit,
        alternativeRoute: Int = 1
    ) {
        Log.d(TAG, "🚶 步行算路: ($fromLat,$fromLng) → ($toLat,$toLng), alternativeRoute=$alternativeRoute")
        walkCallback = callback

        val fromAndTo = RouteSearchV2.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )

        val query = RouteSearchV2.WalkRouteQuery(fromAndTo)
        query.alternativeRoute = alternativeRoute
        query.showFields = RouteSearchV2.ShowFields.ALL

        routeSearchV2.calculateWalkRouteAsyn(query)
    }

    fun calculateRideRoute(
        fromLat: Double, fromLng: Double,
        toLat: Double, toLng: Double,
        callback: (Map<String, Any?>?, String?) -> Unit,
        alternativeRoute: Int = 1
    ) {
        Log.d(TAG, "🚴 骑行算路: ($fromLat,$fromLng) → ($toLat,$toLng), alternativeRoute=$alternativeRoute")
        rideCallback = callback

        val fromAndTo = RouteSearchV2.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )

        val query = RouteSearchV2.RideRouteQuery(fromAndTo)
        query.alternativeRoute = alternativeRoute
        query.showFields = RouteSearchV2.ShowFields.ALL

        routeSearchV2.calculateRideRouteAsyn(query)
    }

    fun calculateBusRoute(
        fromLat: Double, fromLng: Double,
        toLat: Double, toLng: Double,
        city: String,
        mode: Int,
        callback: (Map<String, Any?>?, String?) -> Unit,
        maxTrans: Int = 3,
        alternativeRoute: Int = 1,
        time: String? = null,
        timeType: String? = null,
        destCity: String? = null
    ) {
        Log.d(TAG, "🚌 公交算路: ($fromLat,$fromLng) → ($toLat,$toLng), city=$city, mode=$mode")
        busCallback = callback
        busOrigin = LatLonPoint(fromLat, fromLng)
        busDest = LatLonPoint(toLat, toLng)

        val fromAndTo = RouteSearchV2.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )

        val query = RouteSearchV2.BusRouteQuery(fromAndTo, mode, city, 0)
        query.showFields = RouteSearchV2.ShowFields.ALL
        if (maxTrans in 0..4) query.setMaxTrans(maxTrans)
        if (alternativeRoute in 1..10) query.setAlternativeRoute(alternativeRoute)
        if (!time.isNullOrEmpty()) {
            query.setTime(time)
            if (timeType == "1") query.setDate(time)
        }
        if (!destCity.isNullOrEmpty()) query.setCityd(destCity)

        routeSearchV2.calculateBusRouteAsyn(query)
    }

    fun calculateTruckRoute(
        fromLat: Double, fromLng: Double,
        toLat: Double, toLng: Double,
        strategy: Int,
        callback: (Map<String, Any?>?, String?) -> Unit,
        truckSize: Int = RouteSearch.TRUCK_SIZE_LIGHT,
        truckHeight: Float = 1.6f,
        truckWidth: Float = 2.5f,
        truckLoad: Float = 0.9f,
        truckWeight: Float = 10f,
        truckAxis: Float = 2f
    ) {
        Log.d(TAG, "🚛 货车算路: ($fromLat,$fromLng) → ($toLat,$toLng), strategy=$strategy, size=$truckSize")
        truckCallback = callback

        val fromAndTo = RouteSearch.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )

        val query = RouteSearch.TruckRouteQuery(fromAndTo, strategy, null, truckSize)
        query.setExtensions("all")
        query.setTruckHeight(truckHeight)
        query.setTruckWidth(truckWidth)
        query.setTruckLoad(truckLoad)
        query.setTruckWeight(truckWeight)
        query.setTruckAxis(truckAxis)

        routeSearchV1.calculateTruckRouteAsyn(query)
    }

    fun destroy() {
        driveCallback = null
        walkCallback = null
        rideCallback = null
        busCallback = null
        truckCallback = null
        busOrigin = null
        busDest = null
    }

    // ==================== 驾车序列化（V2） ====================

    private fun serializeDrivePathV2(index: Int, path: DrivePathV2): Map<String, Any?> {
        val polyline = path.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val steps = path.steps?.map { serializeDriveStepV2(it) } ?: emptyList()
        val cost = path.cost
        return mapOf(
            "routeId" to index,
            "distance" to path.distance.toDouble(),
            "duration" to path.duration.toDouble(),
            "tolls" to (cost?.tolls?.toDouble() ?: 0.0),
            "tollDistance" to (cost?.tollDistance?.toDouble() ?: 0.0),
            "tollRoad" to (cost?.tollRoad ?: ""),
            "trafficLights" to (cost?.trafficLights ?: 0),
            "strategy" to (path.strategy ?: ""),
            "strategyId" to _resolveDriveStrategyId(path),
            "restriction" to path.restriction,
            "polyline" to polyline,
            "steps" to steps
        )
    }

    private fun serializeDriveStepV2(step: DriveStepV2): Map<String, Any?> {
        val polyline = step.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val firstCoord = polyline.firstOrNull()
        val cost = step.costDetail
        val tmcList = step.getTMCs()
        val tmcs: List<Map<String, Any?>> = if (tmcList != null) {
            tmcList.map { tmc: com.amap.api.services.route.TMC ->
                mapOf<String, Any?>(
                    "status" to tmc.status,
                    "distance" to tmc.distance,
                    "polyline" to (tmc.polyline?.map { it.toCoordinateMap() } ?: emptyList<Map<String, Double>>())
                )
            }
        } else {
            emptyList()
        }
        val cities = step.routeSearchCityList?.map {
            mapOf(
                "adcode" to (it.searchCityAdCode ?: ""),
                "name" to (it.searchCityName ?: "")
            )
        } ?: emptyList()
        val navi = step.navi
        return mapOf(
            "instruction" to (step.instruction ?: ""),
            "road" to (step.road ?: ""),
            "distance" to step.stepDistance.toDouble(),
            "lat" to (firstCoord?.get("lat") ?: 0.0),
            "lng" to (firstCoord?.get("lng") ?: 0.0),
            "polyline" to polyline,
            "orientation" to (step.orientation ?: ""),
            "chargeLength" to (cost?.tollDistance?.toDouble() ?: 0.0),
            "tollCost" to (cost?.tolls?.toDouble() ?: 0.0),
            "trafficLightCount" to (cost?.trafficLights ?: 0),
            "tmcs" to tmcs,
            "tmcStatus" to deriveTmcStatus(tmcs),
            "cityAdcodes" to cities,
            "naviInstruction" to (navi?.action ?: "")
        )
    }

    private fun _resolveDriveStrategyId(path: DrivePathV2): Int {
        val strategy = path.strategy ?: return 10
        return when {
            strategy.contains("推荐") || strategy.contains("速度优先") -> 10
            strategy.contains("最短时间") || strategy.contains("高速优先") -> 11
            strategy.contains("躲避拥堵") || strategy.contains("避免拥堵") -> 12
            strategy.contains("不走高速") || strategy.contains("高速") -> 13
            strategy.contains("躲避收费") || strategy.contains("费用") -> 14
            strategy.contains("不走高速") && strategy.contains("躲避拥堵") -> 15
            strategy.contains("不走高速") && strategy.contains("费用") -> 16
            strategy.contains("躲避收费") && strategy.contains("拥堵") -> 17
            strategy.contains("避免收费") && strategy.contains("高速") && strategy.contains("拥堵") -> 18
            strategy.contains("高速优先") && !strategy.contains("不走") -> 19
            strategy.contains("高速优先") && strategy.contains("躲避拥堵") -> 20
            else -> 10
        }
    }

    private fun deriveTmcStatus(tmcs: List<Map<String, Any?>>): String {
        if (tmcs.isEmpty()) return "未知"
        return tmcs.maxByOrNull {
            val s = it["status"] as? String ?: ""
            when (s) {
                "严重拥堵" -> 4
                "拥堵" -> 3
                "缓行" -> 2
                "畅通" -> 1
                else -> 0
            }
        }?.get("status")?.toString() ?: "未知"
    }

    // ==================== 步行序列化 ====================

    private fun serializeWalkPath(index: Int, path: WalkPath): Map<String, Any?> {
        val polyline = path.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val steps = path.steps?.map { serializeWalkStep(it) } ?: emptyList()
        return mapOf(
            "routeId" to index,
            "distance" to path.distance.toDouble(),
            "duration" to path.duration.toDouble(),
            "tolls" to 0.0,
            "polyline" to polyline,
            "steps" to steps,
            "trafficLights" to 0
        )
    }

    private fun serializeWalkStep(step: WalkStep): Map<String, Any?> {
        val polyline = step.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val firstCoord = polyline.firstOrNull()
        return mapOf(
            "instruction" to (step.instruction ?: ""),
            "action" to (step.action ?: ""),
            "road" to (step.road ?: ""),
            "distance" to step.distance.toDouble(),
            "duration" to step.duration.toDouble(),
            "lat" to (firstCoord?.get("lat") ?: 0.0),
            "lng" to (firstCoord?.get("lng") ?: 0.0),
            "polyline" to polyline
        )
    }

    // ==================== 骑行序列化 ====================

    private fun serializeRidePath(index: Int, path: RidePath): Map<String, Any?> {
        val polyline = path.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val steps = path.steps?.map { serializeRideStep(it) } ?: emptyList()
        return mapOf(
            "routeId" to index,
            "distance" to path.distance.toDouble(),
            "duration" to path.duration.toDouble(),
            "tolls" to 0.0,
            "polyline" to polyline,
            "steps" to steps,
            "trafficLights" to 0
        )
    }

    private fun serializeRideStep(step: RideStep): Map<String, Any?> {
        val polyline = step.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val firstCoord = polyline.firstOrNull()
        return mapOf(
            "instruction" to (step.instruction ?: ""),
            "action" to (step.action ?: ""),
            "road" to (step.road ?: ""),
            "distance" to step.distance.toDouble(),
            "duration" to step.duration.toDouble(),
            "lat" to (firstCoord?.get("lat") ?: 0.0),
            "lng" to (firstCoord?.get("lng") ?: 0.0),
            "polyline" to polyline
        )
    }

    // ==================== 公交序列化（V2） ====================

    private fun serializeBusPathV2(path: BusPathV2, origin: LatLonPoint?, dest: LatLonPoint?): Map<String, Any?> {
        val steps = path.steps.map { serializeBusStepV2(it) }
        val polyline = path.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        return mapOf(
            "cost" to path.cost.toDouble(),
            "walkDistance" to path.walkDistance.toDouble(),
            "busDistance" to path.busDistance.toDouble(),
            "distance" to path.distance.toDouble(),
            "duration" to path.duration.toDouble(),
            "isNightBus" to path.isNightBus,
            "polyline" to polyline,
            "startPoint" to (origin?.toCoordinateMap()),
            "endPoint" to (dest?.toCoordinateMap()),
            "steps" to steps
        )
    }

    private fun serializeBusStepV2(step: BusStepV2): Map<String, Any?> {
        val stepMap = mutableMapOf<String, Any?>()

        step.walk?.let { walk ->
            val walkPolyline = walk.polyline?.map { it.toCoordinateMap() } ?: emptyList()
            val walkSteps = walk.steps?.map { ws ->
                val stepPoly = ws.polyline?.map { it.toCoordinateMap() } ?: emptyList()
                mapOf(
                    "instruction" to (ws.instruction ?: ""),
                    "road" to (ws.road ?: ""),
                    "distance" to ws.distance.toDouble(),
                    "duration" to ws.duration.toDouble(),
                    "polyline" to stepPoly,
                    "action" to (ws.action ?: ""),
                    "assistantAction" to (ws.assistantAction ?: ""),
                    "orientation" to (ws.orientation ?: ""),
                    "roadType" to ws.roadType
                )
            } ?: emptyList()
            stepMap["walk"] = mapOf(
                "distance" to walk.distance.toDouble(),
                "duration" to walk.duration.toDouble(),
                "polyline" to walkPolyline,
                "steps" to walkSteps
            )
        }

        step.busLines?.let { lines ->
            if (lines.isNotEmpty()) stepMap["busLines"] = lines.map { serializeRouteBusLine(it) }
        }

        step.railway?.let { railway ->
            val stationPoints = mutableListOf<Map<String, Any>>()
            railway.departurestop?.let { stop ->
                stationPoints.add(mapOf(
                    "id" to (stop.id ?: ""), "name" to (stop.name ?: ""),
                    "lat" to (stop.location?.latitude ?: 0.0), "lng" to (stop.location?.longitude ?: 0.0),
                    "time" to (stop.time ?: ""), "wait" to stop.wait.toDouble(),
                    "isStart" to true, "isEnd" to false
                ))
            }
            railway.viastops?.forEach { stop ->
                stationPoints.add(mapOf(
                    "id" to (stop.id ?: ""), "name" to (stop.name ?: ""),
                    "lat" to (stop.location?.latitude ?: 0.0), "lng" to (stop.location?.longitude ?: 0.0),
                    "time" to (stop.time ?: ""), "wait" to stop.wait.toDouble(),
                    "isStart" to false, "isEnd" to false
                ))
            }
            railway.arrivalstop?.let { stop ->
                stationPoints.add(mapOf(
                    "id" to (stop.id ?: ""), "name" to (stop.name ?: ""),
                    "lat" to (stop.location?.latitude ?: 0.0), "lng" to (stop.location?.longitude ?: 0.0),
                    "time" to (stop.time ?: ""), "wait" to stop.wait.toDouble(),
                    "isStart" to false, "isEnd" to true
                ))
            }
            val spaces = railway.spaces?.map { space ->
                mapOf("code" to (space.code ?: ""), "cost" to space.cost.toDouble())
            } ?: emptyList()
            stepMap["railway"] = mapOf(
                "name" to (railway.name ?: ""), "time" to railway.time.toDouble(),
                "trip" to (railway.trip ?: ""), "type" to (railway.type ?: ""),
                "distance" to railway.distance.toDouble(),
                "stations" to stationPoints, "spaces" to spaces
            )
        }

        step.taxi?.let { taxi ->
            stepMap["taxi"] = mapOf(
                "origin" to (taxi.origin?.toCoordinateMap()),
                "destination" to (taxi.destination?.toCoordinateMap()),
                "distance" to taxi.distance.toDouble(),
                "duration" to taxi.duration.toDouble(),
                "price" to taxi.price.toDouble(),
                "polyline" to (taxi.polyline?.map { it.toCoordinateMap() } ?: emptyList())
            )
        }

        step.entrance?.let {
            stepMap["entrance"] = mapOf(
                "name" to (it.name ?: ""),
                "lat" to (it.latLonPoint?.latitude ?: 0.0),
                "lng" to (it.latLonPoint?.longitude ?: 0.0)
            )
        }
        step.exit?.let {
            stepMap["exit"] = mapOf(
                "name" to (it.name ?: ""),
                "lat" to (it.latLonPoint?.latitude ?: 0.0),
                "lng" to (it.latLonPoint?.longitude ?: 0.0)
            )
        }

        return stepMap
    }

    private fun serializeRouteBusLine(item: RouteBusLineItem): Map<String, Any?> {
        val polyline = item.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val passStations = item.passStations?.map { station ->
            mapOf(
                "id" to (station.busStationId ?: ""),
                "name" to (station.busStationName ?: ""),
                "lat" to (station.latLonPoint?.latitude ?: 0.0),
                "lng" to (station.latLonPoint?.longitude ?: 0.0)
            )
        } ?: emptyList()
        val firstTime = item.firstBusTime?.let { formatBusTime(it) } ?: ""
        val lastTime = item.lastBusTime?.let { formatBusTime(it) } ?: ""
        return mapOf(
            "name" to (item.busLineName ?: ""),
            "type" to (item.busLineType ?: ""),
            "departureStation" to (item.departureBusStation?.busStationName ?: ""),
            "arrivalStation" to (item.arrivalBusStation?.busStationName ?: ""),
            "passStationNum" to item.passStationNum,
            "duration" to item.duration.toDouble(),
            "polyline" to polyline,
            "busLineId" to (item.busLineId ?: ""),
            "basicPrice" to item.basicPrice.toDouble(),
            "totalPrice" to item.totalPrice.toDouble(),
            "firstBusTime" to firstTime,
            "lastBusTime" to lastTime,
            "originatingStation" to (item.originatingStation ?: ""),
            "terminalStation" to (item.terminalStation ?: ""),
            "busCompany" to (item.busCompany ?: ""),
            "passStations" to passStations
        )
    }

    // ==================== 货车序列化 ====================

    private fun serializeTruckPath(index: Int, path: TruckPath): Map<String, Any?> {
        val steps = path.steps?.map { serializeTruckStep(it) } ?: emptyList()
        return mapOf(
            "routeId" to index,
            "distance" to path.distance.toDouble(),
            "duration" to path.duration.toDouble(),
            "tolls" to path.tolls.toDouble(),
            "tollDistance" to path.tollDistance.toDouble(),
            "strategy" to (path.strategy ?: ""),
            "steps" to steps
        )
    }

    private fun serializeTruckStep(step: TruckStep): Map<String, Any?> {
        val polyline = step.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val firstCoord = polyline.firstOrNull()
        val tmcList = step.getTMCs()
        val tmcs: List<Map<String, Any?>> = if (tmcList != null) {
            tmcList.map { tmc: com.amap.api.services.route.TMC ->
                mapOf<String, Any?>(
                    "status" to tmc.status,
                    "distance" to tmc.distance,
                    "polyline" to (tmc.polyline?.map { it.toCoordinateMap() } ?: emptyList<Map<String, Double>>())
                )
            }
        } else {
            emptyList()
        }
        return mapOf(
            "instruction" to (step.instruction ?: ""),
            "action" to (step.action ?: ""),
            "road" to (step.road ?: ""),
            "distance" to step.distance.toDouble(),
            "duration" to step.duration.toDouble(),
            "lat" to (firstCoord?.get("lat") ?: 0.0),
            "lng" to (firstCoord?.get("lng") ?: 0.0),
            "polyline" to polyline,
            "orientation" to (step.orientation ?: ""),
            "tollCost" to step.tolls.toDouble(),
            "chargeLength" to step.tollDistance.toDouble(),
            "tollRoad" to (step.tollRoad ?: ""),
            "tmcs" to tmcs,
            "tmcStatus" to deriveTmcStatus(tmcs)
        )
    }

    // ==================== 工具方法 ====================

    private fun formatBusTime(date: java.util.Date?): String {
        return try {
            date?.let { SimpleDateFormat(DATE_FORMAT, Locale.getDefault()).format(it) } ?: ""
        } catch (e: Exception) {
            ""
        }
    }
}
