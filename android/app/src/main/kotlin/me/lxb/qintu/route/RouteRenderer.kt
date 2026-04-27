package me.lxb.qintu.route

import android.util.Log
import com.amap.api.maps.AMap
import com.amap.api.maps.model.BitmapDescriptorFactory
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.LatLngBounds
import com.amap.api.maps.model.Marker
import com.amap.api.maps.model.MarkerOptions
import com.amap.api.maps.model.Polyline
import com.amap.api.maps.model.PolylineOptions

/**
 * 路线渲染器
 */
class RouteRenderer(private val aMap: AMap?) {

    companion object {
        private const val TAG = "RouteRenderer"
        private const val SELECTED_COLOR = 0xFF1890FF.toInt()
        private const val UNSELECTED_COLOR = 0xFF999999.toInt()
        private const val SELECTED_WIDTH = 12f
        private const val UNSELECTED_WIDTH = 8f
    }

    private val routeOverlays = mutableListOf<Polyline>()
    private var selectedRouteIndex = -1
    private var startMarker: Marker? = null
    private var endMarker: Marker? = null

    fun showRoutes(routes: List<List<Map<String, Double>>>, selectIndex: Int): Int {
        Log.d(TAG, "🗺️ [Native] showRoutes 开始执行")

        if (aMap == null) {
            Log.e(TAG, "❌ [Native] 地图未初始化!")
            return 0
        }

        // 清除旧路线
        clearRoutes()

        if (routes.isEmpty()) {
            Log.w(TAG, "⚠️ [Native] routesData 为空")
            return 0
        }

        Log.d(TAG, "🗺️ [Native] 开始遍历 ${routes.size} 条路线")

        var successCount = 0
        for ((index, routeData) in routes.withIndex()) {
            try {
                val points = mutableListOf<LatLng>()

                for (point in routeData) {
                    val lat = point["lat"] ?: continue
                    val lng = point["lng"] ?: continue
                    points.add(LatLng(lat, lng))
                }

                if (points.size < 2) {
                    Log.w(TAG, "⚠️ [Native] 路线 $index 点数不足 (<2), 跳过")
                    continue
                }

                val isSelected = index == selectIndex
                val polyline = aMap!!.addPolyline(
                    PolylineOptions()
                        .addAll(points)
                        .color(if (isSelected) SELECTED_COLOR else UNSELECTED_COLOR)
                        .width(if (isSelected) SELECTED_WIDTH else UNSELECTED_WIDTH)
                )

                routeOverlays.add(polyline)
                successCount++
                Log.d(TAG, "✅ [Native] 成功添加路线 $index: ${points.size} 个点")
            } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 添加路线 $index 失败: ${e.message}")
            }
        }

        selectedRouteIndex = selectIndex

        // 移动相机到路线起点
        if (routeOverlays.isNotEmpty() && selectIndex < routeOverlays.size) {
            val polyline = routeOverlays[selectIndex]
            val points = polyline.points
            if (points.isNotEmpty()) {
                aMap!!.moveCamera(
                    com.amap.api.maps.CameraUpdateFactory.newLatLngBounds(
                        LatLngBounds.builder()
                            .include(points.first())
                            .include(points.last())
                            .build(),
                        100
                    )
                )
            }
        }

        Log.d(TAG, "🗺️ [Native] showRoutes 执行完成, 返回 $successCount 条路线")
        return successCount
    }

    fun selectRoute(index: Int): Boolean {
        Log.d(TAG, "🗺️ [Native] selectRoute 开始执行: index=$index")

        if (aMap == null) {
            Log.e(TAG, "❌ [Native] aMap 为 null")
            return false
        }

        if (routeOverlays.isEmpty()) {
            Log.e(TAG, "❌ [Native] routeOverlays 为空")
            return false
        }

        if (index < 0 || index >= routeOverlays.size) {
            Log.e(TAG, "❌ [Native] 路线索引无效: index=$index, size=${routeOverlays.size}")
            return false
        }

        // 更新所有路线样式
        for ((i, polyline) in routeOverlays.withIndex()) {
            try {
                val newColor = if (i == index) SELECTED_COLOR else UNSELECTED_COLOR
                val newWidth = if (i == index) SELECTED_WIDTH else UNSELECTED_WIDTH
                polyline.color = newColor
                polyline.width = newWidth
            } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 更新路线 $i 样式失败: ${e.message}")
            }
        }

        selectedRouteIndex = index
        Log.d(TAG, "✅ [Native] 选中路线 $index 完成")
        return true
    }

    fun clearRoutes() {
        Log.d(TAG, "🗺️ [Native] clearRoutes: 开始清除 ${routeOverlays.size} 条路线")
        for (polyline in routeOverlays) {
            try {
                polyline.remove()
            } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 移除路线失败: ${e.message}")
            }
        }
        routeOverlays.clear()
        selectedRouteIndex = -1
        clearMarkers()
    }

    fun setMarkers(
        startLat: Double?,
        startLng: Double?,
        endLat: Double?,
        endLng: Double?,
        startLabel: String,
        endLabel: String
    ): Boolean {
        if (aMap == null) {
            Log.e(TAG, "❌ [Native] 地图未初始化!")
            return false
        }

        if (startLat == null || startLng == null || endLat == null || endLng == null) {
            Log.e(TAG, "❌ [Native] 坐标参数不能为空")
            return false
        }

        try {
            clearMarkers()

            val startPoint = LatLng(startLat, startLng)
            val endPoint = LatLng(endLat, endLng)

            // 添加起点标记（绿色）
            startMarker = aMap!!.addMarker(
                MarkerOptions()
                    .position(startPoint)
                    .title(startLabel)
                    .snippet("")
                    .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN))
            )

            // 添加终点标记（红色）
            endMarker = aMap!!.addMarker(
                MarkerOptions()
                    .position(endPoint)
                    .title(endLabel)
                    .snippet("")
                    .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED))
            )

            Log.d(TAG, "✅ [Native] 已添加起点标记: $startLabel ($startLat, $startLng)")
            Log.d(TAG, "✅ [Native] 已添加终点标记: $endLabel ($endLat, $endLng)")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "❌ [Native] 设置路线标记失败: ${e.message}")
            return false
        }
    }

    fun clearMarkers() {
        try {
            startMarker?.let {
                it.remove()
                startMarker = null
            }
            endMarker?.let {
                it.remove()
                endMarker = null
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ [Native] 清除路线标记失败: ${e.message}")
        }
    }
}
