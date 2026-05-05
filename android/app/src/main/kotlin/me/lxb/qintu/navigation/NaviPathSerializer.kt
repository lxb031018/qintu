package me.lxb.qintu.navigation

import com.amap.api.navi.model.AMapNaviPath
import com.amap.api.navi.model.AMapNaviStep
import com.amap.api.navi.model.AMapTrafficStatus
import me.lxb.qintu.util.toCoordinateMap

/**
 * 导航路径序列化工具
 *
 * 职责：将 AMapNaviPath / AMapNaviStep / AMapTrafficStatus 序列化为 Map
 */
object NaviPathSerializer {

    fun serialize(routeId: Int, path: AMapNaviPath): Map<String, Any?> {
        val points = path.coordList.map { it.toCoordinateMap() }
        val steps = path.steps?.map { serializeStep(it) } ?: emptyList()
        val allCameras = path.allCameras
        val trafficStatuses = path.trafficStatuses

        return mapOf(
            "routeId" to routeId,
            "distance" to path.allLength.toDouble(),
            "duration" to path.allTime.toDouble(),
            "tolls" to path.tollCost.toDouble(),
            "strategy" to (path.labels ?: ""),
            "trafficLights" to (path.lightList?.size ?: 0),
            "points" to points,
            "steps" to steps,
            "routeType" to path.routeType,
            "mainRoadInfo" to (path.mainRoadInfo ?: ""),
            "restrictionInfo" to path.restrictionInfo?.let {
                mapOf(
                    "title" to it.restrictionTitle,
                    "titleType" to it.titleType,
                    "tips" to it.tips,
                    "cityCode" to it.cityCode,
                    "cityCodes" to it.cityCodes?.toList(),
                    "desc" to it.restrictionDesc
                )
            },
            "trafficStatuses" to trafficStatuses?.map { serializeTrafficStatus(it) },
            "cityAdcodes" to path.cityAdcodeList?.toList(),
            "cameraCount" to (allCameras?.size ?: 0),
            "naviGuideGroupCount" to (path.naviGuideList?.size ?: 0)
        )
    }

    fun serializeStep(step: AMapNaviStep): Map<String, Any?> {
        val coords = step.coords?.map { it.toCoordinateMap() } ?: emptyList()
        val firstCoord = coords.firstOrNull()
        val links = step.links?.map { link ->
            link.coords?.map { it.toCoordinateMap() } ?: emptyList()
        } ?: emptyList()

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
            "endIndex" to step.endIndex,
            "links" to links,
            "chargeLength" to step.chargeLength.toDouble(),
            "tollCost" to step.tollCost.toDouble(),
            "trafficLightCount" to (step.trafficLightNumber ?: 0),
            "isArriveWayPoint" to step.isArriveWayPoint
        )
    }

    private fun serializeTrafficStatus(ts: AMapTrafficStatus): Map<String, Any?> {
        return mapOf(
            "status" to ts.status,
            "length" to ts.length,
            "linkIndex" to ts.linkIndex
        )
    }
}