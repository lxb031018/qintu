package me.lxb.qintu.bus

import android.content.Context
import android.util.Log
import com.amap.api.services.busline.BusLineItem
import com.amap.api.services.busline.BusLineQuery
import com.amap.api.services.busline.BusLineResult
import com.amap.api.services.busline.BusLineSearch
import com.amap.api.services.busline.BusStationItem
import com.amap.api.services.busline.BusStationQuery
import com.amap.api.services.busline.BusStationResult
import com.amap.api.services.busline.BusStationSearch
import com.amap.api.services.core.AMapException
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.route.BusPathV2
import com.amap.api.services.route.BusRouteResultV2
import com.amap.api.services.route.BusStepV2
import com.amap.api.services.route.RouteBusLineItem
import com.amap.api.services.route.RouteSearchV2
import io.flutter.plugin.common.MethodChannel
import me.lxb.qintu.util.AMapPrivacy
import me.lxb.qintu.util.toCoordinateMap
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.concurrent.atomic.AtomicInteger

/**
 * 公交搜索功能模块
 *
 * 封装高德搜索 SDK 的 BusStationSearch / BusLineSearch / RouteSearchV2
 */
class BusSearchImpl(context: Context) {

    companion object {
        private const val TAG = "BusSearchImpl"
        private const val DATE_FORMAT = "HHmm"

        // 公交算路策略: 0=最快捷, 1=最少换乘, 2=最少步行, 3=不乘地铁, 4=最舒适, 5=最经济
        const val TRANSIT_DEFAULT = 0
    }

    private val stationCallbacks = mutableMapOf<String, MethodChannel.Result>()
    private val lineCallbacks = mutableMapOf<Int, MethodChannel.Result>()
    private var transitCallback: MethodChannel.Result? = null
    private var transitOrigin: LatLonPoint? = null
    private var transitDestination: LatLonPoint? = null
    private var transitInFlight = false

    private val lineRequestId = AtomicInteger(0)

    private val busStationSearch: BusStationSearch = BusStationSearch(context, BusStationQuery("", ""))
    private val busLineSearch: BusLineSearch = BusLineSearch(context, BusLineQuery("", BusLineQuery.SearchType.BY_LINE_NAME, ""))
    private val routeSearchV2: RouteSearchV2 = RouteSearchV2(context)

    init {
        AMapPrivacy.initSearch(context)

        busStationSearch.setOnBusStationSearchListener(object : BusStationSearch.OnBusStationSearchListener {
            override fun onBusStationSearched(result: BusStationResult?, rCode: Int) {
                val requestId = "station_search"
                val callback = stationCallbacks.remove(requestId)
                if (callback == null) {
                    Log.w(TAG, "⚠️ 未找到站台搜索回调")
                    return
                }
                if (rCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val stations = result.busStations.map { serializeStation(it) }
                    callback.success(mapOf(
                        "stations" to stations,
                        "pageCount" to result.pageCount,
                        "suggestionKeywords" to (result.searchSuggestionKeywords ?: emptyList<String>()),
                        "suggestionCities" to result.searchSuggestionCities.map { it.cityName ?: "" }
                    ))
                } else {
                    Log.e(TAG, "❌ 站台搜索失败: rCode=$rCode")
                    callback.error("BUS_STATION_ERROR", "站台搜索失败: $rCode", null)
                }
            }
        })

        busLineSearch.setOnBusLineSearchListener(object : BusLineSearch.OnBusLineSearchListener {
            override fun onBusLineSearched(result: BusLineResult?, rCode: Int) {
                // 使用 requestId 精确匹配（按 FIFO 取出最早的那个）
                val entry = lineCallbacks.entries.firstOrNull()
                if (entry == null) {
                    Log.w(TAG, "⚠️ 未找到线路搜索回调")
                    return
                }
                val callback = lineCallbacks.remove(entry.key)
                if (callback == null) {
                    Log.w(TAG, "⚠️ 线路搜索回调已被移除")
                    return
                }
                if (rCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val lines = result.busLines.map { serializeLineDetail(it) }
                    callback.success(mapOf(
                        "lines" to lines,
                        "pageCount" to result.pageCount,
                        "suggestionKeywords" to (result.searchSuggestionKeywords ?: emptyList<String>()),
                        "suggestionCities" to result.searchSuggestionCities.map { it.cityName ?: "" }
                    ))
                } else {
                    Log.e(TAG, "❌ 线路搜索失败: rCode=$rCode")
                    callback.error("BUS_LINE_ERROR", "线路搜索失败: $rCode", null)
                }
            }
        })

        routeSearchV2.setRouteSearchListener(object : RouteSearchV2.OnRouteSearchListener {
            override fun onBusRouteSearched(result: BusRouteResultV2?, errorCode: Int) {
                val cb = transitCallback
                transitCallback = null
                transitOrigin = null
                transitDestination = null
                transitInFlight = false
                if (cb == null) {
                    Log.w(TAG, "⚠️ 未找到公交算路回调")
                    return
                }
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val paths = result.paths.map { serializeBusPath(it) }
                    cb.success(mapOf("paths" to paths, "taxiCost" to result.taxiCost.toDouble()))
                } else {
                    Log.e(TAG, "❌ 公交算路失败: errorCode=$errorCode")
                    cb.error("TRANSIT_ERROR", "公交算路失败: $errorCode", null)
                }
            }

            override fun onDriveRouteSearched(result: com.amap.api.services.route.DriveRouteResultV2?, errorCode: Int) {}
            override fun onWalkRouteSearched(result: com.amap.api.services.route.WalkRouteResultV2?, errorCode: Int) {}
            override fun onRideRouteSearched(result: com.amap.api.services.route.RideRouteResultV2?, errorCode: Int) {}
        })
    }

    fun searchBusStation(keyword: String, city: String, callback: MethodChannel.Result) {
        Log.d(TAG, "🔍 搜索公交站: keyword=$keyword, city=$city")
        stationCallbacks["station_search"] = callback
        val query = BusStationQuery(keyword, city)
        busStationSearch.query = query
        busStationSearch.searchBusStationAsyn()
    }

    fun searchBusLineByName(keyword: String, city: String, callback: MethodChannel.Result) {
        Log.d(TAG, "🔍 按名称搜索公交线路: keyword=$keyword, city=$city")
        val requestId = lineRequestId.incrementAndGet()
        lineCallbacks[requestId] = callback
        val query = BusLineQuery(keyword, BusLineQuery.SearchType.BY_LINE_NAME, city)
        query.extensions = BusLineSearch.EXTENSIONS_ALL
        busLineSearch.query = query
        busLineSearch.searchBusLineAsyn()
    }

    fun searchBusLineById(lineId: String, city: String, callback: MethodChannel.Result) {
        Log.d(TAG, "🔍 按ID搜索公交线路: lineId=$lineId, city=$city")
        val requestId = lineRequestId.incrementAndGet()
        lineCallbacks[requestId] = callback
        val query = BusLineQuery(lineId, BusLineQuery.SearchType.BY_LINE_ID, city)
        query.extensions = BusLineSearch.EXTENSIONS_ALL
        busLineSearch.query = query
        busLineSearch.searchBusLineAsyn()
    }

    fun calculateTransitRoute(
        fromLat: Double, fromLng: Double,
        toLat: Double, toLng: Double,
        city: String, mode: Int, callback: MethodChannel.Result,
        maxTrans: Int = 3,
        alternativeRoute: Int = 1,
        time: String? = null,
        timeType: String? = null
    ) {
        Log.d(TAG, "🚌 公交算路: ($fromLat,$fromLng) → ($toLat,$toLng), city=$city, mode=$mode, maxTrans=$maxTrans")
        if (transitInFlight) {
            Log.w(TAG, "⚠️ 上一公交算路请求仍在进行中，将替换回调")
        }
        transitCallback = callback
        transitOrigin = LatLonPoint(fromLat, fromLng)
        transitDestination = LatLonPoint(toLat, toLng)
        transitInFlight = true
        val fromAndTo = RouteSearchV2.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )
        val query = RouteSearchV2.BusRouteQuery(fromAndTo, mode, city, 0)
        query.showFields = RouteSearchV2.ShowFields.ALL  // 必须设置，否则 polyline 数据为空
        if (maxTrans in 0..4) {
            query.setMaxTrans(maxTrans)
        }
        if (alternativeRoute in 1..10) {
            query.setAlternativeRoute(alternativeRoute)
        }
        if (!time.isNullOrEmpty()) {
            query.setTime(time)
            if (timeType == "1") {
                query.setDate(time)
            }
        }
        routeSearchV2.calculateBusRouteAsyn(query)
    }

    fun destroy() {
        stationCallbacks.clear()
        lineCallbacks.clear()
        transitCallback = null
        transitInFlight = false
    }

    // ==================== BusRouteResultV2 序列化 ====================

    private fun serializeBusPath(path: BusPathV2): Map<String, Any?> {
        val steps = path.steps.map { serializeBusStep(it) }
        // AMap SDK 不返回首端/末端步行段，起终点坐标作为独立字段传递，
        // 由 Flutter 端步行补充逻辑负责拼接真实路线
        val startPoint = transitOrigin?.let { it.toCoordinateMap() }
        val endPoint = transitDestination?.let { it.toCoordinateMap() }
        val pathPolyline = path.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        return mapOf(
            "cost" to path.cost.toDouble(),
            "walkDistance" to path.walkDistance.toDouble(),
            "busDistance" to path.busDistance.toDouble(),
            "distance" to path.distance.toDouble(),
            "duration" to path.duration.toDouble(),
            "isNightBus" to path.isNightBus,
            "polyline" to pathPolyline,
            "startPoint" to startPoint,
            "endPoint" to endPoint,
            "steps" to steps
        )
    }

    private fun serializeBusStep(step: BusStepV2): Map<String, Any?> {
        val stepMap = mutableMapOf<String, Any?>()

        // 步行段 - 包含路径级 polyline + 步级详细 polyline
        val walk = step.walk
        val busLines = step.busLines
        val railway = step.railway
        if (walk != null) {
            val walkPolyline = walk.polyline?.map { it.toCoordinateMap() } ?: emptyList()
            // 获取步级详细 polyline（比路径级更细）
            val walkSteps = walk.steps?.map { ws ->
                val stepPolyline = ws.polyline?.map { it.toCoordinateMap() } ?: emptyList()
                mapOf(
                    "instruction" to (ws.instruction ?: ""),
                    "road" to (ws.road ?: ""),
                    "distance" to ws.distance.toDouble(),
                    "duration" to ws.duration.toDouble(),
                    "polyline" to stepPolyline,
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

        // 公交段
        if (busLines != null && busLines.isNotEmpty()) {
            stepMap["busLines"] = busLines.map { serializeRouteBusLine(it) }
        }

// 地铁/铁路段
        if (railway != null) {
            val stationPoints = mutableListOf<Map<String, Any>>()
            railway.departurestop?.let { stop ->
                stationPoints.add(mapOf(
                    "id" to (stop.id ?: ""),
                    "name" to (stop.name ?: ""),
                    "lat" to (stop.location?.latitude ?: 0.0),
                    "lng" to (stop.location?.longitude ?: 0.0),
                    "time" to (stop.time ?: ""),
                    "wait" to stop.wait.toDouble(),
                    "isStart" to true,
                    "isEnd" to false
                ))
            }
            railway.viastops?.forEach { stop ->
                stationPoints.add(mapOf(
                    "id" to (stop.id ?: ""),
                    "name" to (stop.name ?: ""),
                    "lat" to (stop.location?.latitude ?: 0.0),
                    "lng" to (stop.location?.longitude ?: 0.0),
                    "time" to (stop.time ?: ""),
                    "wait" to stop.wait.toDouble(),
                    "isStart" to false,
                    "isEnd" to false
                ))
            }
            railway.arrivalstop?.let { stop ->
                stationPoints.add(mapOf(
                    "id" to (stop.id ?: ""),
                    "name" to (stop.name ?: ""),
                    "lat" to (stop.location?.latitude ?: 0.0),
                    "lng" to (stop.location?.longitude ?: 0.0),
                    "time" to (stop.time ?: ""),
                    "wait" to stop.wait.toDouble(),
                    "isStart" to false,
                    "isEnd" to true
                ))
            }
            // 舱位/票价
            val spaces = railway.spaces?.map { space ->
                mapOf(
                    "code" to (space.code ?: ""),
                    "cost" to space.cost.toDouble()
                )
            } ?: emptyList()
            stepMap["railway"] = mapOf(
                "name" to (railway.name ?: ""),
                "time" to railway.time.toDouble(),
                "trip" to (railway.trip ?: ""),
                "type" to (railway.type ?: ""),
                "distance" to railway.distance.toDouble(),
                "stations" to stationPoints,
                "spaces" to spaces
            )
        }

        // 打车段
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

        // 出入口
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

    // ==================== 站台/线路序列化 ====================

    private fun serializeStation(item: BusStationItem): Map<String, Any?> {
        val lines = item.busLineItems?.map { serializeLineBrief(it) } ?: emptyList()
        val point = item.latLonPoint
        return mapOf(
            "id" to (item.busStationId ?: ""),
            "name" to (item.busStationName ?: ""),
            "lat" to (point?.latitude ?: 0.0),
            "lng" to (point?.longitude ?: 0.0),
            "cityCode" to (item.cityCode ?: ""),
            "adCode" to (item.adCode ?: ""),
            "busLines" to lines
        )
    }

    private fun serializeLineBrief(item: BusLineItem): Map<String, Any?> {
        return mapOf(
            "id" to (item.busLineId ?: ""),
            "name" to (item.busLineName ?: ""),
            "type" to (item.busLineType ?: "")
        )
    }

    private fun serializeLineDetail(item: BusLineItem): Map<String, Any?> {
        val stations = item.busStations?.map { station ->
            val point = station.latLonPoint
            mapOf(
                "id" to (station.busStationId ?: ""),
                "name" to (station.busStationName ?: ""),
                "lat" to (point?.latitude ?: 0.0),
                "lng" to (point?.longitude ?: 0.0)
            )
        } ?: emptyList()

        val coords = item.directionsCoordinates?.map { it.toCoordinateMap() } ?: emptyList()

        val firstTime = formatBusTime(item.firstBusTime)
        val lastTime = formatBusTime(item.lastBusTime)

        return mapOf(
            "id" to (item.busLineId ?: ""),
            "name" to (item.busLineName ?: ""),
            "type" to (item.busLineType ?: ""),
            "cityCode" to (item.cityCode ?: ""),
            "originStation" to (item.originatingStation ?: ""),
            "terminalStation" to (item.terminalStation ?: ""),
            "distance" to item.distance.toDouble(),
            "basicPrice" to item.basicPrice.toDouble(),
            "totalPrice" to item.totalPrice.toDouble(),
            "company" to (item.busCompany ?: ""),
            "firstBusTime" to firstTime,
            "lastBusTime" to lastTime,
            "stations" to stations,
            "coordinates" to coords
        )
    }

    private fun formatBusTime(date: java.util.Date?): String {
        return try {
            date?.let { SimpleDateFormat(DATE_FORMAT, Locale.getDefault()).format(it) } ?: ""
        } catch (e: Exception) {
            ""
        }
    }
}
