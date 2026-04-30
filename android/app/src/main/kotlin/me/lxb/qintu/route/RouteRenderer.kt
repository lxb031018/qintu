package me.lxb.qintu.route

import android.content.Context
import android.util.Log
import com.amap.api.maps.AMap
import com.amap.api.maps.model.BitmapDescriptorFactory
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.LatLngBounds
import com.amap.api.maps.model.Marker
import com.amap.api.maps.model.MarkerOptions
import com.amap.api.maps.model.Polyline
import com.amap.api.maps.model.PolylineOptions
import com.amap.api.navi.model.AMapNaviPath
import com.amap.api.navi.view.RouteOverLay

/**
 * 路线渲染器
 */
class RouteRenderer(private val aMap: AMap?, private val context: Context) {

    companion object {
        private const val TAG = "RouteRenderer"
        private const val SELECTED_COLOR = 0xFF1890FF.toInt()
        private const val UNSELECTED_COLOR = 0xFF999999.toInt()
        private const val SELECTED_WIDTH = 12f
        private const val UNSELECTED_WIDTH = 8f
    }

    private val routePolylines = mutableListOf<Polyline>()
    private val routeOverlays = mutableListOf<RouteOverLay>()
    private var selectedRouteIndex = -1
    private var startMarker: Marker? = null
    private var endMarker: Marker? = null

    /**
     * 用坐标点列表绘制路线（Polyline 方式，无方向箭头）
     */
    fun showRoutes(routes: List<List<Map<String, Double>>>, selectIndex: Int): Int {
        Log.d(TAG, "🗺️ [Native] showRoutes 开始执行")

        if (aMap == null) {
            Log.e(TAG, "❌ [Native] 地图未初始化!")
            return 0
        }

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

                routePolylines.add(polyline)
                successCount++
                Log.d(TAG, "✅ [Native] 成功添加路线 $index: ${points.size} 个点")
            } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 添加路线 $index 失败: ${e.message}")
            }
        }

        selectedRouteIndex = selectIndex

        if (routePolylines.isNotEmpty() && selectIndex < routePolylines.size) {
            val polyline = routePolylines[selectIndex]
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

    /**
     * 用 AMapNaviPath 绘制带方向箭头的路线（RouteOverLay 方式）
     */
    fun showRouteOverlays(paths: List<AMapNaviPath>, selectIndex: Int): Int {
        Log.d(TAG, "🗺️ [Native] showRouteOverlays 开始执行, ${paths.size} 条路线")

        if (aMap == null) {
            Log.e(TAG, "❌ [Native] 地图未初始化!")
            return 0
        }

        clearRoutes()

        if (paths.isEmpty()) {
            Log.w(TAG, "⚠️ [Native] paths 为空")
            return 0
        }

        var successCount = 0
        for ((index, path) in paths.withIndex()) {
            try {
                if (path.coordList.size < 2) {
                    Log.w(TAG, "⚠️ [Native] 路线 $index 点数不足 (<2), 跳过")
                    continue
                }

                val overlay = RouteOverLay(aMap, path, context).apply {
                    setArrowOnRoute(true)
                    addToMap()
                }

                routeOverlays.add(overlay)
                successCount++
                Log.d(TAG, "✅ [Native] 成功添加 RouteOverLay $index: ${path.coordList.size} 个点")

                if (index == selectIndex) {
                    overlay.zoomToSpan()
                }
            } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 添加 RouteOverLay $index 失败: ${e.message}")
            }
        }

        selectedRouteIndex = selectIndex
        Log.d(TAG, "🗺️ [Native] showRouteOverlays 执行完成, 返回 $successCount 条路线")
        return successCount
    }

    fun selectRoute(index: Int): Boolean {
        Log.d(TAG, "🗺️ [Native] selectRoute 开始执行: index=$index")

        if (aMap == null) {
            Log.e(TAG, "❌ [Native] aMap 为 null")
            return false
        }

        val hasPolylines = routePolylines.isNotEmpty()
        val hasOverlays = routeOverlays.isNotEmpty()

        if (!hasPolylines && !hasOverlays) {
            Log.e(TAG, "❌ [Native] 无路线可选中")
            return false
        }

        // 更新 Polyline 样式
        if (hasPolylines && index < routePolylines.size) {
            for ((i, polyline) in routePolylines.withIndex()) {
                try {
                    val newColor = if (i == index) SELECTED_COLOR else UNSELECTED_COLOR
                    val newWidth = if (i == index) SELECTED_WIDTH else UNSELECTED_WIDTH
                    polyline.color = newColor
                    polyline.width = newWidth
                } catch (e: Exception) {
                    Log.e(TAG, "❌ [Native] 更新路线 $i 样式失败: ${e.message}")
                }
            }
        }

        // RouteOverLay 本身不支持选中样式切换，通过重建实现

        selectedRouteIndex = index
        Log.d(TAG, "✅ [Native] 选中路线 $index 完成")
        return true
    }

    fun clearRoutes() {
        Log.d(TAG, "🗺️ [Native] clearRoutes: 清除 ${routePolylines.size} 条 Polyline + ${routeOverlays.size} 条 RouteOverLay")

        for (polyline in routePolylines) {
            try {
                polyline.remove()
            } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 移除 Polyline 失败: ${e.message}")
            }
        }
        routePolylines.clear()

        for (overlay in routeOverlays) {
            try {
                overlay.removeFromMap()
            } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 移除 RouteOverLay 失败: ${e.message}")
            }
        }
        routeOverlays.clear()

        selectedRouteIndex = -1
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

            startMarker = aMap!!.addMarker(
                MarkerOptions()
                    .position(startPoint)
                    .title(startLabel)
                    .snippet("")
                    .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN))
            )

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

    fun showSingleMarker(
        lat: Double,
        lng: Double,
        isStart: Boolean,
        label: String
    ): Boolean {
        if (aMap == null) {
            Log.e(TAG, "❌ [Native] 地图未初始化!")
            return false
        }

        try {
            val position = LatLng(lat, lng)
            val markerOptions = MarkerOptions()
                .position(position)
                .title(label)
                .snippet("")
                .icon(BitmapDescriptorFactory.defaultMarker(
                    if (isStart) BitmapDescriptorFactory.HUE_GREEN else BitmapDescriptorFactory.HUE_RED
                ))

            if (isStart) {
                startMarker?.remove()
                startMarker = aMap!!.addMarker(markerOptions)
                Log.d(TAG, "✅ [Native] 已添加起点标记: $label ($lat, $lng)")
            } else {
                endMarker?.remove()
                endMarker = aMap!!.addMarker(markerOptions)
                Log.d(TAG, "✅ [Native] 已添加终点标记: $label ($lat, $lng)")
            }
            return true
        } catch (e: Exception) {
            Log.e(TAG, "❌ [Native] 显示单条路线标记失败: ${e.message}")
            return false
        }
    }

    fun clearSingleMarker(isStart: Boolean) {
        try {
            if (isStart) {
                startMarker?.let {
                    it.remove()
                    startMarker = null
                }
                Log.d(TAG, "🗑️ [Native] 已清除起点标记")
            } else {
                endMarker?.let {
                    it.remove()
                    endMarker = null
                }
                Log.d(TAG, "🗑️ [Native] 已清除终点标记")
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ [Native] 清除单条路线标记失败: ${e.message}")
        }
    }
}
