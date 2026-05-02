package me.lxb.qintu.route

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.Log
import com.amap.api.maps.AMap
import com.amap.api.maps.model.BitmapDescriptorFactory
import com.amap.api.maps.AMapUtils
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.LatLngBounds
import com.amap.api.maps.model.Marker
import com.amap.api.maps.model.MarkerOptions
import com.amap.api.maps.model.Polyline
import com.amap.api.maps.model.PolylineOptions
import com.amap.api.navi.model.AMapNaviPath
import com.amap.api.navi.view.RouteOverLay
import me.lxb.qintu.navigation.NavigationStateHolder

/**
 * 路线渲染器
 */
class RouteRenderer(private val aMap: AMap?, private val context: Context) {

    companion object {
        private const val TAG = "RouteRenderer"
        private var SELECTED_COLOR = 0xFF1890FF.toInt()
        private var UNSELECTED_COLOR = 0x801890FF.toInt()
        private var SELECTED_WIDTH = 14f
        private var UNSELECTED_WIDTH = 9f
        private const val SELECTED_TRANSPARENCY = 1.0f
        private const val UNSELECTED_TRANSPARENCY = 0.4f
        private const val TEXTURE_SIZE = 16
        private const val TEXTURE_DOT_SIZE = 5f
        private const val GRAY_POLYLINE_Z_INDEX = 200f
        private const val GRAY_POLYLINE_COLOR = 0x88888888.toInt()
        private const val GRAY_POLYLINE_WIDTH = 18f
        private const val NAV_ROUTE_OVERLAY_Z_INDEX = 5

    }

    private var showTmcStatus = false
    private var showTrafficIcon = false

    private val routePolylines = mutableListOf<Polyline>()
    private val routeOverlays = mutableListOf<RouteOverLay>()
    private val routeOverlayPaths = mutableListOf<AMapNaviPath>()
    private val navRouteOverlay = mutableListOf<RouteOverLay>()
    private var selectedRouteIndex = -1
    private var hasPerPolylineColors = false
    private val routePolylineColors = mutableListOf<Int>()
    private val routePolylineWidths = mutableListOf<Float>()
    private var startMarker: Marker? = null
    private var endMarker: Marker? = null

    // 导航路线灰度覆盖：在 RouteOverLay 之上手工绘制灰色 Polyline
    private var passedRoutePolyline: Polyline? = null
    private var navRouteFullPoints: List<LatLng> = emptyList()
    private var naviPath: AMapNaviPath? = null

    private val routeTexture by lazy { createRouteTexture() }

    private fun createRouteTexture() =
        BitmapDescriptorFactory.fromBitmap(
            Bitmap.createBitmap(TEXTURE_SIZE, TEXTURE_SIZE, Bitmap.Config.ARGB_8888).apply {
                val canvas = Canvas(this)
                canvas.drawColor(Color.TRANSPARENT)
                val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = Color.WHITE
                    alpha = 180
                    style = Paint.Style.FILL
                }
                canvas.drawCircle(
                    TEXTURE_SIZE / 2f,
                    TEXTURE_SIZE / 2f,
                    TEXTURE_DOT_SIZE,
                    paint
                )
            }
        )

    /**
     * 用坐标点列表绘制路线（纯色 Polyline，无纹理 — 仅当 RouteOverLay 不可用时回退）
     */
    fun showRoutes(
        routes: List<List<Map<String, Double>>>,
        selectIndex: Int,
        colors: List<Int>? = null,
        widths: List<Double>? = null,
        dashedFlags: List<Boolean>? = null
    ): Int {
        Log.d(TAG, "🗺️ [Native] showRoutes (Polyline fallback) 开始执行, colors=${colors?.size}, widths=${widths?.size}")

        if (aMap == null) {
            Log.e(TAG, "❌ [Native] 地图未初始化!")
            return 0
        }

        clearRoutes()

        if (routes.isEmpty()) {
            Log.w(TAG, "⚠️ [Native] routesData 为空")
            return 0
        }

        // Use per-polyline colors only when they differ (e.g. transit segments).
        // When all colors are the same (e.g. driving routes), fall back to
        // selectIndex-based styling so selected/unselected is visually distinct.
        val usePerSegmentColors = colors != null && colors.size == routes.size && colors.distinct().size > 1
        val usePerSegmentWidths = widths != null && widths.size == routes.size && widths.distinct().size > 1
        hasPerPolylineColors = usePerSegmentColors

        var successCount = 0
        for ((index, routeData) in routes.withIndex()) {
            try {
                val points = routeData.mapNotNull { point ->
                    val lat = point["lat"] ?: return@mapNotNull null
                    val lng = point["lng"] ?: return@mapNotNull null
                    LatLng(lat, lng)
                }

                if (points.size < 2) {
                    Log.w(TAG, "⚠️ [Native] 路线 $index 点数不足 (<2), 跳过")
                    continue
                }

                // Per-segment color → use directly (ignore selectIndex)
                // No per-segment color → fall back to selectIndex-based colors
                val polyColor = if (usePerSegmentColors) {
                    colors!![index]
                } else {
                    if (index == selectIndex) SELECTED_COLOR else UNSELECTED_COLOR
                }

                val polyWidth = if (usePerSegmentWidths) {
                    widths!![index].toFloat()
                } else if (usePerSegmentColors) {
                    // Per-segment colors active but no widths → uniform width
                    SELECTED_WIDTH
                } else {
                    if (index == selectIndex) SELECTED_WIDTH else UNSELECTED_WIDTH
                }

                val polyline = if (usePerSegmentColors) {
                    aMap!!.addPolyline(
                        PolylineOptions()
                            .addAll(points)
                            .color(polyColor)
                            .width(polyWidth)
                    )
                } else {
                    aMap!!.addPolyline(
                        PolylineOptions()
                            .addAll(points)
                            .color(polyColor)
                            .width(polyWidth)
                            .setCustomTexture(routeTexture)
                    )
                }

                if (dashedFlags != null && index < dashedFlags.size && dashedFlags[index]) {
                    polyline.setDottedLine(true)
                }

                routePolylines.add(polyline)
                routePolylineColors.add(polyColor)
                routePolylineWidths.add(polyWidth)
                successCount++
                Log.d(TAG, "✅ [Native] 成功添加路线 $index: ${points.size} 个点, color=#${Integer.toHexString(polyColor)}, width=$polyWidth")
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
     * 用 AMapNaviPath 绘制路线（RouteOverLay + 方向箭头 + 透明度）
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

                val isSelected = index == selectIndex
                val overlay = RouteOverLay(aMap, path, context).apply {
                    setArrowOnRoute(isSelected)
                    setTransparency(if (isSelected) SELECTED_TRANSPARENCY else UNSELECTED_TRANSPARENCY)
                    addToMap()
                }

                routeOverlays.add(overlay)
                routeOverlayPaths.add(path)
                successCount++
                Log.d(TAG, "✅ [Native] RouteOverLay $index: 箭头=${if (isSelected) "ON" else "OFF"}, alpha=${if (isSelected) "1.0" else "0.4"}, ${path.coordList.size}pts")

                if (isSelected) {
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

    /**
     * 进入导航模式：RouteOverLay（方向箭头）+ 手动灰色 Polyline 覆盖已过路段。
     * RouteOverLay 的灰线功能需要 AMapNaviView.setAfterRouteAutoGray(true)，
     * 在无 View 导航模式下不可用，因此用高 z-index 灰色 Polyline 覆盖替代。
     */
    fun showNavigateRoute(routeId: Int): Boolean {
        Log.d(TAG, "🚗 [Native] showNavigateRoute: routeId=$routeId")

        if (aMap == null) {
            Log.e(TAG, "❌ [Native] 地图未初始化!")
            return false
        }

        // 清理旧导航数据
        for (overlay in navRouteOverlay) {
            try { overlay.removeFromMap() } catch (e: Exception) {}
        }
        navRouteOverlay.clear()
        passedRoutePolyline?.remove()
        passedRoutePolyline = null
        navRouteFullPoints = emptyList()
        naviPath = null

        val path = RoutePathCache.get(routeId)
        if (path == null) {
            Log.e(TAG, "❌ [Native] 未找到缓存的路径: routeId=$routeId")
            return false
        }

        try {
            naviPath = path
            navRouteFullPoints = path.coordList.map { LatLng(it.latitude, it.longitude) }

            val overlay = RouteOverLay(aMap, path, context).apply {
                setPassRouteVisible(true)
                setZindex(NAV_ROUTE_OVERLAY_Z_INDEX)
                addToMap()
            }
            navRouteOverlay.add(overlay)
            overlay.zoomToSpan()
            Log.d(TAG, "✅ [Native] 导航路线已显示: $routeId (RouteOverLay + 手动灰线覆盖)")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "❌ [Native] 显示导航路线失败: ${e.message}")
            return false
        }
    }

    /**
     * 置灰已行驶路段：在 RouteOverLay 上方绘制灰色 Polyline 覆盖已过路段。
     *
     * 使用 pathRetainDistance 计算已行驶距离，沿路径坐标点逐段累计找到分割点。
     * 灰色 Polyline z-index=200 > RouteOverLay z-index=5，确保灰色覆盖可见。
     */
    fun updatePassedRouteGray(lat: Double, lng: Double) {
        val path = naviPath ?: return

        // 同时尝试 SDK 内置灰线（可能需要 setAfterRouteAutoGray 才生效）
        NavigationStateHolder.naviLocation?.let { location ->
            for (overlay in navRouteOverlay) {
                overlay.updatePolyline(location)
            }
        }

        val retainDist = NavigationStateHolder.pathRetainDistance
        val totalLen = path.allLength
        val isMatched = NavigationStateHolder.isMatched

        if (!isMatched || retainDist <= 0 || retainDist > totalLen) return

        val passedDistance = totalLen - retainDist
        if (passedDistance <= 0) return

        var accumulated = 0f
        var splitIdx = 0
        for (i in 1 until navRouteFullPoints.size) {
            val segDist = AMapUtils.calculateLineDistance(
                navRouteFullPoints[i - 1], navRouteFullPoints[i]
            )
            accumulated += segDist
            if (accumulated >= passedDistance) {
                splitIdx = i
                break
            }
        }

        // 已走完整条路线：灰色覆盖所有点
        if (splitIdx == 0 && accumulated < passedDistance) {
            splitIdx = navRouteFullPoints.size - 1
        }

        if (splitIdx < 1) return

        val passedPoints = navRouteFullPoints.subList(0, splitIdx + 1)
        if (passedPoints.size < 2) return

        if (passedRoutePolyline == null) {
            passedRoutePolyline = aMap?.addPolyline(
                PolylineOptions()
                    .addAll(passedPoints)
                    .color(GRAY_POLYLINE_COLOR)
                    .width(GRAY_POLYLINE_WIDTH)
                    .zIndex(GRAY_POLYLINE_Z_INDEX)
            )
        } else {
            passedRoutePolyline?.points = passedPoints
        }
    }

    fun selectRoute(index: Int): Boolean {
        Log.d(TAG, "🗺️ [Native] selectRoute: index=$index")

        if (aMap == null) {
            Log.e(TAG, "❌ [Native] aMap 为 null")
            return false
        }

        // RouteOverLay 模式：清除后按新选中状态重建（同时更新透明度+箭头）
        if (routeOverlays.isNotEmpty()) {
            val paths = routeOverlayPaths.toList()
            if (index < 0 || index >= paths.size) {
                Log.e(TAG, "❌ [Native] 路线索引无效: index=$index, size=${paths.size}")
                return false
            }
            clearRoutes()
            return showRouteOverlays(paths, index) > 0
        }

        // Polyline 模式（回退）：更新颜色和宽度
        if (routePolylines.isEmpty()) {
            Log.e(TAG, "❌ [Native] 无路线可选中")
            return false
        }

        if (index < 0 || index >= routePolylines.size) {
            Log.e(TAG, "❌ [Native] 路线索引无效: index=$index, size=${routePolylines.size}")
            return false
        }

        // 有自定义每段颜色时，不修改它们（Flutter 会重新调用 showRoutes 更新选中状态）
        if (hasPerPolylineColors) {
            Log.d(TAG, "✅ [Native] 每段颜色已预设，跳过 selectRoute 颜色更新")
            selectedRouteIndex = index
            return true
        }

        for ((i, polyline) in routePolylines.withIndex()) {
            try {
                polyline.color = if (i == index) SELECTED_COLOR else UNSELECTED_COLOR
                polyline.width = if (i == index) SELECTED_WIDTH else UNSELECTED_WIDTH
            } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 更新路线 $i 样式失败: ${e.message}")
            }
        }

        selectedRouteIndex = index
        Log.d(TAG, "✅ [Native] 选中路线 $index 完成")
        return true
    }

    fun clearRoutes() {
        Log.d(TAG, "🗺️ [Native] clearRoutes: ${routePolylines.size} Polyline + ${routeOverlays.size} RouteOverLay + ${navRouteOverlay.size} nav")

        for (polyline in routePolylines) {
            try { polyline.remove() } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 移除 Polyline 失败: ${e.message}")
            }
        }
        routePolylines.clear()
        hasPerPolylineColors = false
        routePolylineColors.clear()
        routePolylineWidths.clear()

        for (overlay in routeOverlays) {
            try { overlay.removeFromMap() } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 移除 RouteOverLay 失败: ${e.message}")
            }
        }
        routeOverlays.clear()
        routeOverlayPaths.clear()

        for (overlay in navRouteOverlay) {
            try { overlay.removeFromMap() } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 移除导航 RouteOverLay 失败: ${e.message}")
            }
        }
        navRouteOverlay.clear()

        passedRoutePolyline?.remove()
        passedRoutePolyline = null
        navRouteFullPoints = emptyList()
        naviPath = null

        selectedRouteIndex = -1
    }

    fun setMarkers(
        startLat: Double?, startLng: Double?,
        endLat: Double?, endLng: Double?,
        startLabel: String, endLabel: String
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

            startMarker = aMap!!.addMarker(
                MarkerOptions()
                    .position(LatLng(startLat, startLng))
                    .title(startLabel)
                    .snippet("")
                    .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN))
            )

            endMarker = aMap!!.addMarker(
                MarkerOptions()
                    .position(LatLng(endLat, endLng))
                    .title(endLabel)
                    .snippet("")
                    .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED))
            )

            Log.d(TAG, "✅ [Native] 已添加起点: $startLabel, 终点: $endLabel")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "❌ [Native] 设置路线标记失败: ${e.message}")
            return false
        }
    }

    fun clearMarkers() {
        try {
            startMarker?.remove()
            startMarker = null
            endMarker?.remove()
            endMarker = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ [Native] 清除路线标记失败: ${e.message}")
        }
    }

    fun showSingleMarker(lat: Double, lng: Double, isStart: Boolean, label: String): Boolean {
        if (aMap == null) {
            Log.e(TAG, "❌ [Native] 地图未初始化!")
            return false
        }

        try {
            val markerOptions = MarkerOptions()
                .position(LatLng(lat, lng))
                .title(label)
                .snippet("")
                .icon(BitmapDescriptorFactory.defaultMarker(
                    if (isStart) BitmapDescriptorFactory.HUE_GREEN else BitmapDescriptorFactory.HUE_RED
                ))

            if (isStart) {
                startMarker?.remove()
                startMarker = aMap!!.addMarker(markerOptions)
            } else {
                endMarker?.remove()
                endMarker = aMap!!.addMarker(markerOptions)
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
                startMarker?.remove()
                startMarker = null
            } else {
                endMarker?.remove()
                endMarker = null
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ [Native] 清除单条路线标记失败: ${e.message}")
        }
    }

    // ======== 路线样式控制 ========

    fun setTmcEnabled(enabled: Boolean) {
        showTmcStatus = enabled
        // RouteOverLay 不直接支持 setShowTmcStatus — TMC 由 AMapNavi 层控制
        Log.d(TAG, "🚦 TMC 路况颜色: ${if (enabled) "显示" else "隐藏"}")
    }

    fun setTrafficIconEnabled(enabled: Boolean) {
        showTrafficIcon = enabled
        // RouteOverLay 不直接支持 setShowTrafficIcon — 交通事件图标由 AMapNavi 层控制
        Log.d(TAG, "🚧 交通事件图标: ${if (enabled) "显示" else "隐藏"}")
    }

    fun updateRouteStyle(
        selectedColor: Int? = null,
        unselectedColor: Int? = null,
        selectedWidth: Float? = null,
        unselectedWidth: Float? = null
    ) {
        selectedColor?.let { SELECTED_COLOR = it }
        unselectedColor?.let { UNSELECTED_COLOR = it }
        selectedWidth?.let { SELECTED_WIDTH = it }
        unselectedWidth?.let { UNSELECTED_WIDTH = it }
        Log.d(TAG, "🎨 路线样式已更新: sel=${Integer.toHexString(SELECTED_COLOR)}/${SELECTED_WIDTH}, unsel=${Integer.toHexString(UNSELECTED_COLOR)}/${UNSELECTED_WIDTH}")
    }
}
