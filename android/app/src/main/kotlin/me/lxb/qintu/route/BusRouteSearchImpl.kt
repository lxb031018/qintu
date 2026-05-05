package me.lxb.qintu.route

import android.content.Context
import android.util.Log
import com.amap.api.services.core.AMapException
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.route.*
import me.lxb.qintu.util.AMapPrivacy

/**
 * 公交路线搜索功能模块
 *
 * 封装高德搜索 SDK 的 RouteSearchV2 公共交通路径规划
 */
class BusRouteSearchImpl(private val context: Context) {

    companion object {
        private const val TAG = "BusRouteSearchImpl"
    }

    private val routeSearch: RouteSearchV2 by lazy {
        AMapPrivacy.initSearch(context)
        RouteSearchV2(context)
    }

    fun calculateBusRoute(
        fromLat: Double,
        fromLng: Double,
        toLat: Double,
        toLng: Double,
        city: String,
        mode: Int = RouteSearchV2.BusMode.BUS_DEFAULT,
        nightFlag: Int = 0
    ): List<Map<String, Any?>> {
        Log.d(TAG, "🚌 计算公交路线: from=($fromLat,$fromLng), to=($toLat,$toLng), city=$city, mode=$mode")

        val fromAndTo = RouteSearchV2.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )

        val query = RouteSearchV2.BusRouteQuery(fromAndTo, mode, city, nightFlag)
        query.setShowFields(RouteSearchV2.ShowFields.ALL)

        return try {
            val result = routeSearch.calculateBusRoute(query)
            parseBusPaths(result)
        } catch (e: AMapException) {
            Log.e(TAG, "❌ 公交路线计算异常: ${e.errorCode} ${e.message}")
            emptyList()
        }
    }

    private fun parseBusPaths(result: BusRouteResultV2?): List<Map<String, Any?>> {
        if (result == null) {
            Log.w(TAG, "⚠️ 公交路线结果为空")
            return emptyList()
        }

        val paths = result.paths
        if (paths.isNullOrEmpty()) {
            Log.w(TAG, "⚠️ 无公交路线方案")
            return emptyList()
        }

        Log.d(TAG, "📍 获取到 ${paths.size} 条公交路线方案")

        return paths.mapIndexed { index, busPath ->
            val segments = parseSegments(busPath.steps)
            mapOf(
                "routeId" to index,
                "distance" to busPath.distance.toDouble(),
                "duration" to busPath.duration.toLong(),
                "cost" to busPath.cost.toDouble(),
                "nightBus" to busPath.isNightBus,
                "walkDistance" to busPath.walkDistance.toDouble(),
                "busDistance" to busPath.busDistance.toDouble(),
                "points" to busPath.polyline.map { latLonPoint ->
                    listOf(latLonPoint.longitude, latLonPoint.latitude)
                },
                "segments" to segments
            )
        }
    }

    private fun parseSegments(steps: List<BusStepV2>?): List<Map<String, Any?>> {
        if (steps.isNullOrEmpty()) return emptyList()

        val segments = mutableListOf<Map<String, Any?>>()

        for (step in steps) {
            // 步行路段
            val walk = step.walk
            if (walk != null && walk.distance > 0) {
                val walkPolyline = walk.polyline
                if (walkPolyline.isNotEmpty()) {
                    val walkSteps = walk.steps?.map { wStep ->
                        mapOf(
                            "instruction" to (wStep.instruction ?: ""),
                            "action" to (wStep.action ?: ""),
                            "road" to (wStep.road ?: ""),
                            "distance" to wStep.distance.toDouble(),
                            "duration" to wStep.duration.toDouble(),
                            "points" to wStep.polyline.map { listOf(it.longitude, it.latitude) }
                        )
                    } ?: emptyList()

                    segments.add(mapOf(
                        "type" to "walk",
                        "lineName" to null,
                        "distance" to walk.distance.toDouble(),
                        "duration" to walk.duration.toDouble(),
                        "points" to walkPolyline.map { listOf(it.longitude, it.latitude) },
                        "walkSteps" to walkSteps
                    ))
                }
            }

            // 公交/地铁路段
            val busLines = step.busLines
            if (!busLines.isNullOrEmpty()) {
                for (busLine in busLines) {
                    val lineType = categorizeBusLine(busLine)
                    val departureStation = busLine.departureBusStation?.let { station ->
                        mapOf(
                            "name" to (station.busStationName ?: ""),
                            "lat" to (station.latLonPoint?.latitude ?: 0.0),
                            "lng" to (station.latLonPoint?.longitude ?: 0.0)
                        )
                    }
                    val arrivalStation = busLine.arrivalBusStation?.let { station ->
                        mapOf(
                            "name" to (station.busStationName ?: ""),
                            "lat" to (station.latLonPoint?.latitude ?: 0.0),
                            "lng" to (station.latLonPoint?.longitude ?: 0.0)
                        )
                    }
                    val passStations = busLine.passStations?.map { station ->
                        mapOf(
                            "id" to (station.busStationId ?: ""),
                            "name" to (station.busStationName ?: ""),
                            "lat" to (station.latLonPoint?.latitude ?: 0.0),
                            "lng" to (station.latLonPoint?.longitude ?: 0.0)
                        )
                    } ?: emptyList()

                    segments.add(mapOf(
                        "type" to lineType,
                        "lineName" to (busLine.busLineName ?: ""),
                        "busLineId" to (busLine.busLineId ?: ""),
                        "lineType" to (busLine.busLineType ?: ""),
                        "distance" to busLine.distance.toDouble(),
                        "duration" to busLine.duration.toDouble(),
                        "stationCount" to (busLine.passStationNum + 1), // 经过站数不含出发站，含到达站
                        "departureStation" to departureStation,
                        "arrivalStation" to arrivalStation,
                        "basicPrice" to busLine.basicPrice?.toDouble(),
                        "totalPrice" to busLine.totalPrice?.toDouble(),
                        "firstBusTime" to (busLine.firstBusTime ?: ""),
                        "lastBusTime" to (busLine.lastBusTime ?: ""),
                        "originatingStation" to (busLine.originatingStation ?: ""),
                        "terminalStation" to (busLine.terminalStation ?: ""),
                        "busCompany" to (busLine.busCompany ?: ""),
                        "passStations" to passStations,
                        "points" to (busLine.directionsCoordinates?.map { listOf(it.longitude, it.latitude) }
                            ?: emptyList<List<Double>>())
                    ))
                }
            }

            // 火车路段
            val railway = step.railway
            if (railway != null) {
                val departureStop = railway.departurestop?.let { stop ->
                    val loc = stop.location
                    mapOf(
                        "id" to (stop.id ?: ""),
                        "name" to (stop.name ?: ""),
                        "lat" to (loc?.latitude ?: 0.0),
                        "lng" to (loc?.longitude ?: 0.0),
                        "time" to (stop.time ?: ""),
                        "wait" to (stop.wait ?: 0f).toDouble(),
                        "isStart" to stop.isStart,
                        "isEnd" to stop.isEnd
                    )
                }
                val arrivalStop = railway.arrivalstop?.let { stop ->
                    val loc = stop.location
                    mapOf(
                        "id" to (stop.id ?: ""),
                        "name" to (stop.name ?: ""),
                        "lat" to (loc?.latitude ?: 0.0),
                        "lng" to (loc?.longitude ?: 0.0),
                        "time" to (stop.time ?: ""),
                        "wait" to (stop.wait ?: 0f).toDouble(),
                        "isStart" to stop.isStart,
                        "isEnd" to stop.isEnd
                    )
                }
                val viaStops = railway.viastops?.map { stop ->
                    val loc = stop.location
                    mapOf(
                        "id" to (stop.id ?: ""),
                        "name" to (stop.name ?: ""),
                        "lat" to (loc?.latitude ?: 0.0),
                        "lng" to (loc?.longitude ?: 0.0),
                        "time" to (stop.time ?: ""),
                        "wait" to (stop.wait ?: 0f).toDouble(),
                        "isStart" to stop.isStart,
                        "isEnd" to stop.isEnd
                    )
                } ?: emptyList()
                val spaces = railway.spaces?.map { space ->
                    mapOf("code" to (space.code ?: ""), "cost" to (space.cost ?: 0f).toDouble())
                } ?: emptyList()

                segments.add(mapOf(
                    "type" to "railway",
                    "lineName" to (railway.name ?: railway.trip ?: ""),
                    "trip" to (railway.trip ?: ""),
                    "railwayType" to (railway.type ?: ""),
                    "distance" to railway.distance.toDouble(),
                    "duration" to (railway.time?.toDoubleOrNull() ?: 0.0),
                    "departureStation" to departureStop,
                    "arrivalStation" to arrivalStop,
                    "viaStations" to viaStops,
                    "spaces" to spaces,
                    "points" to emptyList<List<Double>>()
                ))
            }

            // 打车路段
            val taxi = step.taxi
            if (taxi != null) {
                segments.add(mapOf(
                    "type" to "taxi",
                    "lineName" to null,
                    "distance" to taxi.distance.toDouble(),
                    "duration" to taxi.duration.toDouble(),
                    "price" to taxi.price?.toDouble(),
                    "origin" to taxi.origin?.let { listOf(it.longitude, it.latitude) },
                    "destination" to taxi.destination?.let { listOf(it.longitude, it.latitude) },
                    "points" to (taxi.polyline?.map { listOf(it.longitude, it.latitude) }
                        ?: emptyList<List<Double>>())
                ))
            }

            // 地铁进出站口
            val entrance = step.entrance
            val exit = step.exit
            if (entrance != null || exit != null) {
                // 找到最近的公交段，把 entrance/exit 附加上去
                val lastTransitIndex = segments.indexOfLast { seg ->
                    val t = seg["type"] as? String
                    return@indexOfLast t == "subway" || t == "bus" || t == "suburban"
                }
                if (lastTransitIndex >= 0) {
                    val seg = segments[lastTransitIndex].toMutableMap()
                    if (entrance != null) {
                        val loc = entrance.latLonPoint
                        seg["entrance"] = mapOf(
                            "name" to (entrance.name ?: ""),
                            "lat" to (loc?.latitude ?: 0.0),
                            "lng" to (loc?.longitude ?: 0.0)
                        )
                    }
                    if (exit != null) {
                        val loc = exit.latLonPoint
                        seg["exit"] = mapOf(
                            "name" to (exit.name ?: ""),
                            "lat" to (loc?.latitude ?: 0.0),
                            "lng" to (loc?.longitude ?: 0.0)
                        )
                    }
                    segments[lastTransitIndex] = seg
                }
            }
        }

        return segments
    }

    /**
     * 根据公交线路类型判断是地铁还是普通公交
     */
    private fun categorizeBusLine(busLine: RouteBusLineItem): String {
        val lineType = busLine.busLineType ?: ""
        return when {
            lineType.contains("地铁") || lineType.contains("轨交") || lineType.contains("MTR") -> "subway"
            lineType.contains("机场") && (lineType.contains("大巴") || lineType.contains("快线")) -> "bus"
            else -> "bus"
        }
    }
}
