package me.lxb.qintu.route

import com.amap.api.services.route.BusStepV2
import com.amap.api.services.route.Doorway
import com.amap.api.services.route.RouteBusLineItem
import com.amap.api.services.route.*

/**
 * 公交路线分段解析器
 *
 * 职责：解析 BusStepV2 中的 walk/bus/subway/railway/taxi/entrance-exit
 */
object BusSegmentParser {

    private const val TAG = "BusSegmentParser"

    fun parseSegments(steps: List<BusStepV2>?, cityCode: String): List<Map<String, Any?>> {
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

                    // 构建坐标点：优先使用 directionsCoordinates，否则用站点坐标回退
                    val directionsCoords = busLine.directionsCoordinates
                    val segPoints = if (directionsCoords != null && directionsCoords.isNotEmpty()) {
                        directionsCoords.map { listOf(it.longitude, it.latitude) }
                    } else {
                        val fallback = mutableListOf<List<Double>>()
                        busLine.departureBusStation?.latLonPoint?.let {
                            fallback.add(listOf(it.longitude, it.latitude))
                        }
                        busLine.passStations?.forEach { station ->
                            station.latLonPoint?.let {
                                fallback.add(listOf(it.longitude, it.latitude))
                            }
                        }
                        busLine.arrivalBusStation?.latLonPoint?.let {
                            if (fallback.isEmpty() || fallback.last()[0] != it.longitude || fallback.last()[1] != it.latitude) {
                                fallback.add(listOf(it.longitude, it.latitude))
                            }
                        }
                        fallback
                    }
                    if (segPoints.isEmpty()) continue

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
                        "firstBusTime" to (busLine.firstBusTime?.toString() ?: ""),
                        "lastBusTime" to (busLine.lastBusTime?.toString() ?: ""),
                        "originatingStation" to (busLine.originatingStation ?: ""),
                        "terminalStation" to (busLine.terminalStation ?: ""),
                        "busCompany" to (busLine.busCompany ?: ""),
                        "passStations" to passStations,
                        "cityCode" to cityCode,
                        "points" to segPoints
                    ))
                }
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
                        ?: run {
                            val fallback = mutableListOf<List<Double>>()
                            taxi.origin?.let { fallback.add(listOf(it.longitude, it.latitude)) }
                            taxi.destination?.let {
                                if (fallback.isEmpty() || fallback.last()[0] != it.longitude || fallback.last()[1] != it.latitude) {
                                    fallback.add(listOf(it.longitude, it.latitude))
                                }
                            }
                            fallback
                        })
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
            lineType.contains("机场") && (lineType.contains("大巴") || lineType.contains("快线")) -> "bus"
            else -> "bus"
        }
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
            return@indexOfLast t == "subway" || t == "bus"
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
