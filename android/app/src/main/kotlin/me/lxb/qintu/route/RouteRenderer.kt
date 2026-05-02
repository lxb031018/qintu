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
        private const val NAV_ROUTE_OVERLAY_Z_INDEX = 5

    }

    private var showTmcStatus = false
    private var showTrafficIcon = false

    private val routeOverlays = mutableListOf<RouteOverLay>()
    private val routeOverlayPaths = mutableListOf<AMapNaviPath>()
    private val navRouteOverlay = mutableListOf<RouteOverLay>()
    private var selectedRouteIndex = -1
    private var startMarker: Marker? = null
    private var endMarker: Marker? = null

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
     * 进入导航模式：RouteOverLay（方向箭头）。
     */
    fun showNavigateRoute(routeId: Int): Boolean {
        Log.d(TAG, "🚗 [Native] showNavigateRoute: routeId=$routeId")

        if (aMap == null) {
            Log.e(TAG, "❌ [Native] 地图未初始化!")
            return false
        }

        for (overlay in navRouteOverlay) {
            try { overlay.removeFromMap() } catch (e: Exception) {}
        }
        navRouteOverlay.clear()

        val path = RoutePathCache.get(routeId)
        if (path == null) {
            Log.e(TAG, "❌ [Native] 未找到缓存的路径: routeId=$routeId")
            return false
        }

        try {
            val overlay = RouteOverLay(aMap, path, context).apply {
                setPassRouteVisible(true)
                setZindex(NAV_ROUTE_OVERLAY_Z_INDEX)
                addToMap()
            }
            navRouteOverlay.add(overlay)
            overlay.zoomToSpan()
            Log.d(TAG, "✅ [Native] 导航路线已显示: $routeId")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "❌ [Native] 显示导航路线失败: ${e.message}")
            return false
        }
    }

    fun selectRoute(index: Int): Boolean {
        Log.d(TAG, "🗺️ [Native] selectRoute: index=$index")

        if (aMap == null) {
            Log.e(TAG, "❌ [Native] aMap 为 null")
            return false
        }

        if (routeOverlays.isEmpty()) {
            Log.e(TAG, "❌ [Native] 无路线可选中")
            return false
        }

        val paths = routeOverlayPaths.toList()
        if (index < 0 || index >= paths.size) {
            Log.e(TAG, "❌ [Native] 路线索引无效: index=$index, size=${paths.size}")
            return false
        }

        clearRoutes()
        return showRouteOverlays(paths, index) > 0
    }

    fun clearRoutes() {
        Log.d(TAG, "🗺️ [Native] clearRoutes: ${routeOverlays.size} RouteOverLay + ${navRouteOverlay.size} nav")

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
