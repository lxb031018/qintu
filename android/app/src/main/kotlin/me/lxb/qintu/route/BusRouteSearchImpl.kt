package me.lxb.qintu.route

import android.content.Context
import android.util.Log
import com.amap.api.maps.MapsInitializer
import com.amap.api.services.core.AMapException
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.route.BusRouteResultV2
import com.amap.api.services.route.DriveRouteResultV2
import com.amap.api.services.route.RideRouteResultV2
import com.amap.api.services.route.RouteSearchV2
import com.amap.api.services.route.WalkRouteResultV2
import io.flutter.plugin.common.MethodChannel
import me.lxb.qintu.util.AMapPrivacy

/**
 * 公交路线搜索功能模块
 *
 * 封装高德搜索 SDK 的 RouteSearchV2 公共交通路径规划
 * 使用异步 API（calculateBusRouteAsyn），与项目中其他 AMap 服务一致
 */
class BusRouteSearchImpl(private val context: Context) {

    companion object {
        private const val TAG = "BusRouteSearchImpl"
    }

    private val busRouteCallbacks = mutableMapOf<String, Pair<MethodChannel.Result, String>>()

    private val routeSearch: RouteSearchV2 by lazy {
        AMapPrivacy.initSearch(context)
        MapsInitializer.initialize(context)
        RouteSearchV2(context)
    }

    init {
        routeSearch.setRouteSearchListener(object : RouteSearchV2.OnRouteSearchListener {
            override fun onBusRouteSearched(result: BusRouteResultV2?, errorCode: Int) {
                val callbackPair = busRouteCallbacks.remove("bus_route")
                if (callbackPair == null) {
                    Log.w(TAG, "⚠️ 未找到公交路线搜索回调")
                    return
                }
                val (callback, cityCode) = callbackPair
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    Log.d(TAG, "✅ 公交路线搜索成功: ${result.paths?.size ?: 0} 条方案")
                    callback.success(parseBusPaths(result, cityCode))
                } else {
                    Log.e(TAG, "❌ 公交路线搜索失败: errorCode=$errorCode")
                    callback.error("BUS_ROUTE_ERROR", "公交路线搜索失败: $errorCode", null)
                }
            }

            override fun onDriveRouteSearched(result: DriveRouteResultV2?, errorCode: Int) {}
            override fun onWalkRouteSearched(result: WalkRouteResultV2?, errorCode: Int) {}
            override fun onRideRouteSearched(result: RideRouteResultV2?, errorCode: Int) {}
        })
    }

    fun calculateBusRoute(
        fromLat: Double,
        fromLng: Double,
        toLat: Double,
        toLng: Double,
        city: String,
        cityCode: String,
        mode: Int = RouteSearchV2.BusMode.BUS_DEFAULT,
        nightFlag: Int = 0,
        callback: MethodChannel.Result
    ) {
        Log.d(TAG, "🚌 计算公交路线: from=($fromLat,$fromLng), to=($toLat,$toLng), city=$city, cityCode=$cityCode, mode=$mode")

        val fromAndTo = RouteSearchV2.FromAndTo(
            LatLonPoint(fromLat, fromLng),
            LatLonPoint(toLat, toLng)
        )

        val query = RouteSearchV2.BusRouteQuery(fromAndTo, mode, city, nightFlag)
        query.setShowFields(RouteSearchV2.ShowFields.ALL)

        busRouteCallbacks["bus_route"] = callback to cityCode
        routeSearch.calculateBusRouteAsyn(query)
    }

    fun destroy() {
        busRouteCallbacks.clear()
    }

    private fun parseBusPaths(result: BusRouteResultV2?, cityCode: String): List<Map<String, Any?>> {
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
            val segments = BusSegmentParser.parseSegments(busPath.steps, cityCode)
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
