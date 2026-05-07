package me.lxb.qintu.route

import com.amap.api.services.route.Doorway
import com.amap.api.services.route.BusStepV2
import com.amap.api.services.route.RouteBusLineItem
import com.amap.api.services.route.*

/**
 * 公交路线分段解析器
 *
 * 职责：解析 BusStepV2 中的 walk/bus/subway/railway/taxi/entrance-exit
 */
object BusSegmentParser {

    private const val TAG = "BusSegmentParser"

    fun parseSegments(steps: List<BusStepV2>?): List<Map<String, Any?>> {
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
                        "stationCount" to (busLine.passStationNum + 1),
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
                    "points" to buildRailwayPolyline(railway)
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
            attachEntranceExit(segments, step.entrance, step.exit)
        }

        return segments
    }

    /**
     * 根据公交线路类型判断是地铁还是普通公交
     */
    fun categorizeBusLine(busLine: RouteBusLineItem): String {
        val lineType = busLine.busLineType ?: ""
        return when {
            lineType.contains("地铁") || lineType.contains("轨交") || lineType.contains("MTR") -> "subway"
            lineType.contains("郊区") || lineType.contains("市域") || lineType.contains("城际") -> "suburban"
            lineType.contains("机场") && (lineType.contains("大巴") || lineType.contains("快线")) -> "bus"
            else -> "bus"
        }
    }

    /**
     * 构建铁路轨迹点列表
     * 使用 departureStop + viaStops + arrivalStop 的位置构建
     */
    private fun buildRailwayPolyline(railway: RouteRailwayItem): List<List<Double>> {
        val points = mutableListOf<List<Double>>()
        val departureStop = railway.departurestop
        if (departureStop?.location != null) {
            points.add(listOf(departureStop.location.longitude, departureStop.location.latitude))
        }
        val viaStops = railway.viastops
        if (!viaStops.isNullOrEmpty()) {
            for (stop in viaStops) {
                if (stop.location != null) {
                    points.add(listOf(stop.location.longitude, stop.location.latitude))
                }
            }
        }
        val arrivalStop = railway.arrivalstop
        if (arrivalStop?.location != null) {
            points.add(listOf(arrivalStop.location.longitude, arrivalStop.location.latitude))
        }
        return points
    }

    /**
     * 将地铁进出口信息附加到最近的公交段上
     */
    private fun attachEntranceExit(
        segments: MutableList<Map<String, Any?>>,
        entrance: Doorway?,
        exit: Doorway?
    ) {
        if (entrance == null && exit == null) return

        val lastTransitIndex = segments.indexOfLast { seg ->
            val t = seg["type"] as? String
            return@indexOfLast t == "subway" || t == "bus" || t == "suburban"
        }
        if (lastTransitIndex >= 0) {
            val seg = segments[lastTransitIndex].toMutableMap()
            if (entrance != null) {
                seg["entrance"] = mapOf(
                    "name" to (entrance.name ?: ""),
                    "lat" to (entrance.latLonPoint?.latitude ?: 0.0),
                    "lng" to (entrance.latLonPoint?.longitude ?: 0.0)
                )
            }
            if (exit != null) {
                seg["exit"] = mapOf(
                    "name" to (exit.name ?: ""),
                    "lat" to (exit.latLonPoint?.latitude ?: 0.0),
                    "lng" to (exit.latLonPoint?.longitude ?: 0.0)
                )
            }
            segments[lastTransitIndex] = seg
        }
    }
}