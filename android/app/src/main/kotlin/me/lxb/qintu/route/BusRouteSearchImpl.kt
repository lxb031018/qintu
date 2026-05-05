package me.lxb.qintu.route

import android.content.Context
import android.util.Log
import com.amap.api.services.core.AMapException
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.route.BusRouteResultV2
import com.amap.api.services.route.RouteSearchV2
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
            val segments = BusSegmentParser.parseSegments(busPath.steps)
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
}