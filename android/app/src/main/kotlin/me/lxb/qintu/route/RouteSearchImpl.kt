package me.lxb.qintu.route

import android.content.Context
import android.util.Log
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.route.DrivePath
import com.amap.api.services.route.DriveRouteResultV2
import com.amap.api.services.route.RidePath
import com.amap.api.services.route.RideRouteResultV2
import com.amap.api.services.route.RouteSearchV2
import com.amap.api.services.route.TruckPath
import com.amap.api.services.route.TruckRouteResultV2
import com.amap.api.services.route.WalkPath
import com.amap.api.services.route.WalkRouteResultV2
import com.amap.api.services.route.BusPathV2
import com.amap.api.services.route.BusRouteResultV2
import com.amap.api.services.route.BusStepV2
import com.amap.api.services.route.DriveStep
import com.amap.api.services.route.RideStep
import com.amap.api.services.route.WalkStep
import com.amap.api.services.route.RouteBusLineItem
import com.amap.api.services.core.AMapException
import me.lxb.qintu.util.AMapPrivacy
import me.lxb.qintu.util.toCoordinateMap
import java.text.SimpleDateFormat
import java.util.Locale

class RouteSearchImpl(private val context: Context) {

    companion object {
        private const val TAG = "RouteSearchImpl"
        private const val DATE_FORMAT = "HHmm"
    }

    private var driveCallback: ((result: Map<String, Any?>?, error: String?) -> Unit)? = null
    private var walkCallback: ((result: Map<String, Any?>?, error: String?) -> Unit)? = null
    private var rideCallback: ((result: Map<String, Any?>?, error: String?) -> Unit)? = null
    private var truckCallback: ((result: Map<String, Any?>?, error: String?) -> Unit)? = null
    private var busCallback: ((result: Map<String, Any?>?, error: String?) -> Unit)? = null

    private val routeSearchV2: RouteSearchV2 = RouteSearchV2(context)

    init {
        AMapPrivacy.initSearch(context)
        routeSearchV2.setRouteSearchListener(object : RouteSearchV2.OnRouteSearchListener {
            override fun onDriveRouteSearched(result: DriveRouteResultV2?, errorCode: Int) {
                val cb = driveCallback; driveCallback = null
                if (cb == null) { Log.w(TAG, "⚠️ 未找到驾车算路回调"); return }
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val paths = result.paths.mapIndexed { index, path -> serializeDrivePath(index, path) }
                    cb(mapOf("paths" to paths, "taxiCost" to result.taxiCost.toDouble()), null)
                } else {
                    cb(null, "驾车算路失败: $errorCode")
                }
            }

            override fun onWalkRouteSearched(result: WalkRouteResultV2?, errorCode: Int) {
                val cb = walkCallback; walkCallback = null
                if (cb == null) { Log.w(TAG, "⚠️ 未找到步行算路回调"); return }
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val paths = result.paths.mapIndexed { index, path -> serializeWalkPath(index, path) }
                    cb(mapOf("paths" to paths), null)
                } else {
                    cb(null, "步行算路失败: $errorCode")
                }
            }

            override fun onRideRouteSearched(result: RideRouteResultV2?, errorCode: Int) {
                val cb = rideCallback; rideCallback = null
                if (cb == null) { Log.w(TAG, "⚠️ 未找到骑行算路回调"); return }
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val paths = result.paths.mapIndexed { index, path -> serializeRidePath(index, path) }
                    cb(mapOf("paths" to paths), null)
                } else {
                    cb(null, "骑行算路失败: $errorCode")
                }
            }

            override fun onTruckRouteSearched(result: TruckRouteResultV2?, errorCode: Int) {
                val cb = truckCallback; truckCallback = null
                if (cb == null) { Log.w(TAG, "⚠️ 未找到货车算路回调"); return }
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val paths = result.paths.mapIndexed { index, path -> serializeTruckPath(index, path) }
                    cb(mapOf("paths" to paths, "taxiCost" to result.taxiCost.toDouble()), null)
                } else {
                    cb(null, "货车算路失败: $errorCode")
                }
            }

            override fun onBusRouteSearched(result: BusRouteResultV2?, errorCode: Int) {
                val cb = busCallback; busCallback = null
                if (cb == null) { Log.w(TAG, "⚠️ 未找到公交算路回调"); return }
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val paths = result.paths.map { serializeBusPath(it) }
                    cb(mapOf("paths" to paths, "taxiCost" to result.taxiCost.toDouble()), null)
                } else {
                    cb(null, "公交算路失败: $errorCode")
                }
            }
        })
    }

    fun calculateDriveRoute(
        fromLat: Double, fromLng: Double,
        toLat: Double, toLng: Double,
        strategy: Int,
        callback: (result: Map<String, Any?>?, error: String?) -> Unit,
        alternativeRoute: Int = 1,
        avoidRoad: String? = null,
        avoidPolygons: String? = null,
        passedByPoints: String? = null,
        multiPreferences: Int = 0
    ) {
        Log.d(TAG, "🚗 驾车算路: ($fromLat,$fromLng) → ($toLat,$toLng), strategy=$strategy")
        if (driveCallback != null) {
            Log.w(TAG, "⚠️ 上一驾车算路请求仍在进行中，将替换回调")
        }
        driveCallback = callback

        val fromAndTo = RouteSearchV2.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )

        val query = RouteSearchV2.DriveRouteQuery(fromAndTo, strategy, null, null, "")
        query.showFields = RouteSearchV2.ShowFields.ALL

        if (alternativeRoute in 1..10) {
            query.setAlternativeRoute(alternativeRoute)
        }
        if (!avoidRoad.isNullOrEmpty()) {
            query.setAvoidRoad(avoidRoad)
        }
        if (!avoidPolygons.isNullOrEmpty()) {
            query.setAvoidpolygonsStr(avoidPolygons)
        }
        if (!passedByPoints.isNullOrEmpty()) {
            query.setPassedPointStr(passedByPoints)
        }
        if (multiPreferences > 0) {
            query.setMultiPreferences(multiPreferences)
        }

        routeSearchV2.calculateDriveRouteAsyn(query)
    }

    fun calculateWalkRoute(
        fromLat: Double, fromLng: Double,
        toLat: Double, toLng: Double,
        callback: (result: Map<String, Any?>?, error: String?) -> Unit
    ) {
        Log.d(TAG, "🚶 步行算路: ($fromLat,$fromLng) → ($toLat,$toLng)")
        if (walkCallback != null) {
            Log.w(TAG, "⚠️ 上一步行算路请求仍在进行中，将替换回调")
        }
        walkCallback = callback

        val fromAndTo = RouteSearchV2.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )

        val query = RouteSearchV2.WalkRouteQuery(fromAndTo, RouteSearchV2.WalkDefault)
        query.showFields = RouteSearchV2.ShowFields.ALL

        routeSearchV2.calculateWalkRouteAsyn(query)
    }

    fun calculateRideRoute(
        fromLat: Double, fromLng: Double,
        toLat: Double, toLng: Double,
        callback: (result: Map<String, Any?>?, error: String?) -> Unit
    ) {
        Log.d(TAG, "🚴 骑行算路: ($fromLat,$fromLng) → ($toLat,$toLng)")
        if (rideCallback != null) {
            Log.w(TAG, "⚠️ 上一骑行算路请求仍在进行中，将替换回调")
        }
        rideCallback = callback

        val fromAndTo = RouteSearchV2.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )

        val query = RouteSearchV2.RideRouteQuery(fromAndTo, RouteSearchV2.RideDefault)
        query.showFields = RouteSearchV2.ShowFields.ALL

        routeSearchV2.calculateRideRouteAsyn(query)
    }

    fun calculateTruckRoute(
        fromLat: Double, fromLng: Double,
        toLat: Double, toLng: Double,
        strategy: Int,
        callback: (result: Map<String, Any?>?, error: String?) -> Unit,
        carType: Int = 0,
        truckHeight: Double = 0.0,
        truckWeight: Double = 0.0,
        truckWidth: Double = 0.0,
        truckLength: Double = 0.0,
        truckAxis: Int = 0
    ) {
        Log.d(TAG, "🚛 货车算路: ($fromLat,$fromLng) → ($toLat,$toLng), strategy=$strategy, carType=$carType")
        if (truckCallback != null) {
            Log.w(TAG, "⚠️ 上一货车算路请求仍在进行中，将替换回调")
        }
        truckCallback = callback

        val fromAndTo = RouteSearchV2.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )

        val query = RouteSearchV2.TruckRouteQuery(fromAndTo, strategy, null, "")
        query.showFields = RouteSearchV2.ShowFields.ALL
        query.setCarType(carType)
        if (truckHeight > 0) query.setTruckHeight(truckHeight)
        if (truckWeight > 0) query.setTruckWeight(truckWeight)
        if (truckWidth > 0) query.setTruckWidth(truckWidth)
        if (truckLength > 0) query.setTruckLength(truckLength)
        if (truckAxis > 0) query.setTruckAxis(truckAxis)

        routeSearchV2.calculateTruckRouteAsyn(query)
    }

    fun calculateBusRoute(
        fromLat: Double, fromLng: Double,
        toLat: Double, toLng: Double,
        city: String,
        mode: Int,
        callback: (result: Map<String, Any?>?, error: String?) -> Unit,
        maxTrans: Int = 3,
        alternativeRoute: Int = 1,
        time: String? = null,
        timeType: String? = null,
        destCity: String? = null
    ) {
        Log.d(TAG, "🚌 公交算路: ($fromLat,$fromLng) → ($toLat,$toLng), city=$city, mode=$mode")
        if (busCallback != null) {
            Log.w(TAG, "⚠️ 上一公交算路请求仍在进行中，将替换回调")
        }
        busCallback = callback

        val fromAndTo = RouteSearchV2.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )

        val query = RouteSearchV2.BusRouteQuery(fromAndTo, mode, city, 0)
        query.showFields = RouteSearchV2.ShowFields.ALL
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
        if (!destCity.isNullOrEmpty()) {
            query.setCityd(destCity)
        }

        routeSearchV2.calculateBusRouteAsyn(query)
    }

    fun destroy() {
        driveCallback = null
        walkCallback = null
        rideCallback = null
        truckCallback = null
        busCallback = null
    }

    private fun serializeDrivePath(index: Int, path: DrivePath): Map<String, Any?> {
        val polyline = path.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val steps = path.steps?.map { serializeDriveStep(it) } ?: emptyList()
        return mapOf(
            "routeId" to index,
            "distance" to path.distance.toDouble(),
            "duration" to path.duration.toDouble(),
            "strategy" to path.strategy,
            "tolls" to path.tolls.toDouble(),
            "polyline" to polyline,
            "steps" to steps,
            "trafficLights" to (path.lightNum ?: 0),
            "mainRoadInfo" to (path.mainRoad ?: ""),
            "restrictionInfo" to path.restrictionInfo?.let {
                mapOf(
                    "title" to it.restrictionTitle,
                    "desc" to it.restrictionDesc,
                    "cityCode" to it.cityCode,
                    "cityCodes" to it.cityCodes?.toList()
                )
            }
        )
    }

    private fun serializeDriveStep(step: DriveStep): Map<String, Any?> {
        val polyline = step.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val firstCoord = polyline.firstOrNull()
        return mapOf(
            "instruction" to (step.instruction ?: ""),
            "action" to (step.action ?: ""),
            "road" to (step.road ?: ""),
            "distance" to step.distance.toDouble(),
            "duration" to step.time.toDouble(),
            "lat" to (firstCoord?.get("lat") ?: 0.0),
            "lng" to (firstCoord?.get("lng") ?: 0.0),
            "polyline" to polyline,
            "tmcStatus" to (step.tmcStatus ?: ""),
            "chargeLength" to step.chargeLength.toDouble(),
            "tollCost" to step.tollCost.toDouble(),
            "trafficLightCount" to (step.lightNum ?: 0)
        )
    }

    private fun serializeWalkPath(index: Int, path: WalkPath): Map<String, Any?> {
        val polyline = path.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val steps = path.steps?.map { serializeWalkStep(it) } ?: emptyList()
        return mapOf(
            "routeId" to index,
            "distance" to path.distance.toDouble(),
            "duration" to path.duration.toDouble(),
            "strategy" to path.strategy,
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
            "duration" to step.time.toDouble(),
            "lat" to (firstCoord?.get("lat") ?: 0.0),
            "lng" to (firstCoord?.get("lng") ?: 0.0),
            "polyline" to polyline
        )
    }

    private fun serializeRidePath(index: Int, path: RidePath): Map<String, Any?> {
        val polyline = path.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val steps = path.steps?.map { serializeRideStep(it) } ?: emptyList()
        return mapOf(
            "routeId" to index,
            "distance" to path.distance.toDouble(),
            "duration" to path.duration.toDouble(),
            "strategy" to path.strategy,
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
            "duration" to step.time.toDouble(),
            "lat" to (firstCoord?.get("lat") ?: 0.0),
            "lng" to (firstCoord?.get("lng") ?: 0.0),
            "polyline" to polyline
        )
    }

    private fun serializeTruckPath(index: Int, path: TruckPath): Map<String, Any?> {
        val polyline = path.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val steps = path.steps?.map { serializeTruckStep(it) } ?: emptyList()
        return mapOf(
            "routeId" to index,
            "distance" to path.distance.toDouble(),
            "duration" to path.duration.toDouble(),
            "strategy" to path.strategy,
            "tolls" to path.tolls.toDouble(),
            "polyline" to polyline,
            "steps" to steps,
            "trafficLights" to (path.lightNum ?: 0),
            "mainRoadInfo" to (path.mainRoad ?: ""),
            "restrictionInfo" to path.restrictionInfo?.let {
                mapOf(
                    "title" to it.restrictionTitle,
                    "desc" to it.restrictionDesc,
                    "cityCode" to it.cityCode,
                    "cityCodes" to it.cityCodes?.toList()
                )
            }
        )
    }

    private fun serializeTruckStep(step: com.amap.api.services.route.TruckStep): Map<String, Any?> {
        val polyline = step.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        val firstCoord = polyline.firstOrNull()
        return mapOf(
            "instruction" to (step.instruction ?: ""),
            "action" to (step.action ?: ""),
            "road" to (step.road ?: ""),
            "distance" to step.distance.toDouble(),
            "duration" to step.time.toDouble(),
            "lat" to (firstCoord?.get("lat") ?: 0.0),
            "lng" to (firstCoord?.get("lng") ?: 0.0),
            "polyline" to polyline,
            "tmcStatus" to (step.tmcStatus ?: ""),
            "chargeLength" to step.chargeLength.toDouble(),
            "tollCost" to step.tollCost.toDouble(),
            "trafficLightCount" to (step.lightNum ?: 0)
        )
    }

    private fun serializeBusPath(path: BusPathV2): Map<String, Any?> {
        val steps = path.steps.map { serializeBusStep(it) }
        val startPoint = path.startPos?.toCoordinateMap()
        val endPoint = path.endPos?.toCoordinateMap()
        val pathPolyline = path.polyline?.map { it.toCoordinateMap() } ?: emptyList()
        return mapOf(
            "routeId" to 0,
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

        val walk = step.walk
        val busLines = step.busLines
        val railway = step.railway

        if (walk != null) {
            val walkPolyline = walk.polyline?.map { it.toCoordinateMap() } ?: emptyList()
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

        if (busLines != null && busLines.isNotEmpty()) {
            stepMap["busLines"] = busLines.map { serializeRouteBusLine(it) }
        }

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
        if (polyline.isEmpty()) {
            Log.w(TAG, "⚠️ 公交线路 [${item.busLineName}] polyline 为空！")
        }
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

    private fun formatBusTime(date: java.util.Date?): String {
        return try {
            date?.let { SimpleDateFormat(DATE_FORMAT, Locale.getDefault()).format(it) } ?: ""
        } catch (e: Exception) {
            ""
        }
    }
}