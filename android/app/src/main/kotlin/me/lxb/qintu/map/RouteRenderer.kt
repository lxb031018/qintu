package me.lxb.qintu.map

import android.util.Log
import com.amap.api.maps.AMap
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.Polyline
import com.amap.api.maps.model.PolylineOptions
import com.amap.api.navi.AMapNaviView
import com.amap.api.navi.view.RouteOverLay
import me.lxb.qintu.route.RoutePathCache

/**
 * 路线渲染器（功能模块层）
 *
 * 职责：
 * - 管理 Polyline 渲染（自定义路线）
 * - 管理 RouteOverLay 渲染（SDK 原生路线）
 * - 处理路线选择高亮
 */
class RouteRenderer(
    private val aMapHolder: AMapHolder,
    private val naviViewRef: () -> AMapNaviView?
) {
    companion object {
        private const val TAG = "RouteRenderer"
    }

    // AMapNaviView 加载状态
    private var isNaviViewLoaded = false

    // 路线数据就绪状态
    private var isRouteReady = false

    // 待渲染的路线 ID（视图未加载时暂存）
    private val pendingRouteIds = mutableListOf<Int>()
    private var pendingSelectIndex = 0

    // Polyline 渲染状态
    private val routePolylines = mutableListOf<Polyline>()

    // RouteOverLay 渲染状态
    private val routeOverlays = mutableMapOf<Int, RouteOverLay>()

    private var currentSelectedIndex: Int = 0
    private val routeColors = listOf(
        0xFF1890FF.toInt(),
        0x8000FFFF.toInt(),
        0x8000FF00.toInt(),
        0x80FF8800.toInt(),
        0x80FF0088.toInt()
    )

    fun setNaviView(view: AMapNaviView?) {
        if (view != null) {
            view.setAMapNaviViewListener(object : com.amap.api.navi.AMapNaviViewListener {
                override fun onNaviViewLoaded() {
                    isNaviViewLoaded = true
                    Log.d(TAG, "✅ AMapNaviView 加载完成")
                    if (pendingRouteIds.isNotEmpty()) {
                        Log.d(TAG, "📍 渲染暂存的 ${pendingRouteIds.size} 条路线")
                        showRoutesWithOverlayInternal(pendingRouteIds.toList(), pendingSelectIndex)
                        pendingRouteIds.clear()
                    }
                }

                override fun onNaviSetting() {}
                override fun onNaviCancel() {}
                override fun onNaviBackClick(): Boolean = false
                override fun onNaviMapMode(p0: Int) {}
                override fun onNaviTurnClick() {}
                override fun onNextRoadClick() {}
                override fun onScanViewButtonClick() {}
                override fun onLockMap(p0: Boolean) {}
                override fun onNaviViewShowMode(p0: Int) {}
                override fun onStopSpeaking() {}
                override fun onViewTypeChanged(p0: com.amap.api.navi.AmapPageType?) {}
                override fun onAMapNaviViewExit() {}
                override fun onListenToVoiceDuringCallChanged(p0: Boolean) {}
                override fun onControlMusicVolumeModeChanged(p0: Int) {}
                override fun onEagleChanged(p0: Boolean) {}
                override fun onNaviRouteHighlightChange(p0: Long, p1: Int) {}
                override fun onBroadcastModeChanged(p0: Int) {}
                override fun onDayAndNightModeChanged(p0: Int) {}
                override fun onScaleAutoChanged(p0: Boolean) {}
                override fun onStrategyChanged(p0: Int) {}
                override fun onMapTypeChanged(p0: Int) {}
            })
        } else {
            isNaviViewLoaded = false
        }
    }

    // ========== Polyline 渲染（自定义路线）==========

    fun showRoutes(routesData: List<*>?, selectIndex: Int): Int {
        clearRoutePolylinesInternal()

        if (routesData.isNullOrEmpty()) {
            return 0
        }

        val aMap = aMapHolder.aMap ?: return 0

        try {
            routesData.forEachIndexed { index, routeData ->
                val routeMap = routeData as? Map<*, *>
                val polylineList = routeMap?.get("polyline") as? List<*>
                if (polylineList != null) {
                    val latLngs = polylineList.mapNotNull { item ->
                        val coord = item as? Map<*, *>
                        val lat = (coord?.get("lat") as? Number)?.toDouble()
                        val lng = (coord?.get("lng") as? Number)?.toDouble()
                        if (lat != null && lng != null) LatLng(lat, lng) else null
                    }
                    if (latLngs.isNotEmpty()) {
                        val color = if (index == selectIndex) routeColors[0] else routeColors.getOrElse(index % routeColors.size) { routeColors[1] }
                        val lineWidth = if (index == selectIndex) 14f else 10f
                        val polyline = aMap.addPolyline(PolylineOptions()
                            .addAll(latLngs)
                            .color(color)
                            .width(lineWidth)
                            .setDottedLine(false))
                        routePolylines.add(polyline)
                    }
                }
            }
            currentSelectedIndex = selectIndex
            Log.d(TAG, "✅ showRoutes: rendered ${routePolylines.size} polylines, selected=$selectIndex")
            return routePolylines.size
        } catch (e: Exception) {
            Log.e(TAG, "❌ showRoutes 失败: ${e.message}")
            return 0
        }
    }

    fun selectRoute(index: Int) {
        if (index < 0 || index >= routePolylines.size) return
        currentSelectedIndex = index
        val aMap = aMapHolder.aMap ?: return
        try {
            routePolylines.forEachIndexed { i, polyline ->
                val color = if (i == index) routeColors[0] else routeColors.getOrElse(i % routeColors.size) { routeColors[1] }
                val lineWidth = if (i == index) 14f else 10f
                polyline.color = color
                polyline.width = lineWidth
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ selectRoute 失败: ${e.message}")
        }
    }

    fun clearRoutes() {
        clearRoutePolylinesInternal()
    }

    private fun clearRoutePolylinesInternal() {
        try {
            routePolylines.forEach { it.remove() }
            routePolylines.clear()
            currentSelectedIndex = 0
        } catch (e: Exception) {
            Log.e(TAG, "❌ clearRoutePolylinesInternal 失败: ${e.message}")
        }
    }

    // ========== RouteOverLay 渲染（SDK 路线）==========

    fun showRoutesWithOverlay(routeIds: List<Int>, selectIndex: Int): Int {
        if (routeIds.isEmpty()) {
            clearRouteOverlaysInternal()
            isRouteReady = false
            return 0
        }

        pendingRouteIds.clear()
        pendingRouteIds.addAll(routeIds)
        pendingSelectIndex = selectIndex
        isRouteReady = true

        val naviView = naviViewRef()
        if (naviView == null) {
            Log.w(TAG, "⚠️ showRoutesWithOverlay: naviView is null，暂存路线")
            return 0
        }

        if (!isNaviViewLoaded) {
            Log.w(TAG, "⚠️ showRoutesWithOverlay: AMapNaviView 尚未加载完成，暂存路线")
            return 0
        }

        return showRoutesWithOverlayInternal(routeIds, selectIndex)
    }

    private fun showRoutesWithOverlayInternal(routeIds: List<Int>, selectIndex: Int): Int {
        if (!isNaviViewLoaded) {
            Log.w(TAG, "⚠️ showRoutesWithOverlayInternal: NaviView 未加载，拒绝渲染")
            return 0
        }
        if (!isRouteReady) {
            Log.w(TAG, "⚠️ showRoutesWithOverlayInternal: 路线数据未就绪，拒绝渲染")
            return 0
        }

        clearRouteOverlaysInternal()

        val aMap = aMapHolder.aMap ?: return 0
        val naviView = this.naviViewRef() ?: return 0

        routeIds.forEachIndexed { index, routeId ->
            val path = RoutePathCache.get(routeId) ?: return@forEachIndexed

            val overlay = RouteOverLay(aMap, path, naviView.context).apply {
                setTransparency(if (index == selectIndex) 1.0f else 0.6f)
                setZindex(if (index == selectIndex) 100 else 0)
                addToMap()
            }
            routeOverlays[routeId] = overlay
        }

        currentSelectedIndex = selectIndex
        Log.d(TAG, "✅ showRoutesWithOverlayInternal: rendered ${routeOverlays.size} routes, selected=$selectIndex")
        return routeOverlays.size
    }

    fun highlightRoute(routeId: Int) {
        if (!isNaviViewLoaded) {
            Log.w(TAG, "⚠️ highlightRoute: NaviView 未加载，忽略")
            return
        }
        routeOverlays.forEach { (id, overlay) ->
            if (id == routeId) {
                overlay.setTransparency(1.0f)
                overlay.setZindex(100)
            } else {
                overlay.setTransparency(0.6f)
                overlay.setZindex(0)
            }
        }
        Log.d(TAG, "✅ highlightRoute: selected routeId=$routeId")
    }

    fun clearRouteOverlays() {
        clearRouteOverlaysInternal()
    }

    private fun clearRouteOverlaysInternal() {
        try {
            routeOverlays.values.forEach { it.removeFromMap() }
            routeOverlays.clear()
            isRouteReady = false
        } catch (e: Exception) {
            Log.e(TAG, "❌ clearRouteOverlaysInternal failed: ${e.message}")
        }
    }
}