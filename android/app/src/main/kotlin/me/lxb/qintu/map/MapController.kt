package me.lxb.qintu.map

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.amap.api.maps.AMapUtils
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.Marker
import com.amap.api.maps.model.MarkerOptions
import com.amap.api.maps.model.BitmapDescriptorFactory
import com.amap.api.maps.model.Polyline
import com.amap.api.maps.model.PolylineOptions
import com.amap.api.navi.AMapNaviView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import me.lxb.qintu.geocode.GeocodeImpl
import me.lxb.qintu.location.LocationClientImpl
import me.lxb.qintu.map.AMapHolder
import me.lxb.qintu.overlay.CarOverlay

/**
 * 地图业务控制器（功能模块层）
 *
 * 负责处理地图相关的所有业务逻辑：
 * - 定位管理
 * - 路线渲染
 * - 标记管理
 * - 相机控制
 * - 车载标记
 *
 * Plugin 层仅负责 Flutter 通信，不含业务逻辑
 */
class MapController(
    private val locationClient: LocationClientImpl,
    private val geocodeImpl: GeocodeImpl,
    private val cameraController: CameraController,
    private val aMapHolder: AMapHolder,
    private val carOverlayRef: () -> CarOverlay?,
    private val onCarOverlayDestroyed: () -> Unit,
    var isFollowMode: Boolean = false
) {
    companion object {
        private const val TAG = "MapController"
        private const val AUTO_RELOCK_DELAY_MS = 6000L
    }

    // Lock/unlock state for navigation
    private var isLocked: Boolean = false
    private var autoRelockHandler: Handler? = null

    // Marker references for route start/end
    private var startMarker: Marker? = null
    private var endMarker: Marker? = null

    // Current AMapNaviView for SDK route operations
    private var naviView: AMapNaviView? = null

    // Multi-route rendering
    private val routePolylines = mutableListOf<Polyline>()
    private var currentSelectedIndex: Int = 0
    private val routeColors = listOf(
        0xFF1890FF.toInt(),   // 选中-蓝色
        0x8000FFFF.toInt(),   // 其他1-青色半透明
        0x8000FF00.toInt(),   // 其他2-绿色半透明
        0x80FF8800.toInt(),   // 其他3-橙色半透明
        0x80FF0088.toInt()    // 其他4-紫色半透明
    )

    fun setNaviView(view: AMapNaviView?) {
        naviView = view
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

    private fun highlightRouteInternal(index: Int) {
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
            Log.e(TAG, "❌ highlightRouteInternal 失败: ${e.message}")
        }
    }

    private fun clearMarkersInternal() {
        try {
            startMarker?.remove()
            startMarker = null
            endMarker?.remove()
            endMarker = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ clearMarkersInternal 失败: ${e.message}")
        }
    }

    /**
     * 处理来自定位监听器的位置更新，驱动 CarOverlay 自车标记绘制
     */
    fun onLocationChanged(lat: Double, lng: Double, bearing: Float) {
        carOverlayRef()?.draw(aMapHolder.aMap, LatLng(lat, lng), bearing)
    }

    /**
     * 用户触摸地图时调用：解锁相机并安排 6 秒后自动重新锁定
     */
    fun onMapTouched() {
        if (isFollowMode && isLocked) {
            isLocked = false
            autoRelockHandler?.removeCallbacksAndMessages(null)
            autoRelockHandler = Handler(Looper.getMainLooper())
            autoRelockHandler?.postDelayed({
                isLocked = true
                Log.d(TAG, "🔒 触摸超时后自动重新锁定")
            }, AUTO_RELOCK_DELAY_MS)
            Log.d(TAG, "👆 地图被触摸，解锁相机 — ${AUTO_RELOCK_DELAY_MS}ms 后自动重新锁定")
        }
    }

    /**
     * 处理来自 Plugin 层的 MethodCall
     */
    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startLocation" -> {
                Log.d(TAG, "📡 startLocation")
                locationClient.startLocation()
                result.success(true)
            }

            "moveToMyLocation" -> {
                Log.d(TAG, "🎯 moveToMyLocation")
                val lastLoc = locationClient.getLastKnownLocation()
                if (lastLoc != null) {
                    cameraController.moveCameraToCenter(lastLoc.latitude, lastLoc.longitude)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }

            "getCurrentLocation" -> {
                Log.d(TAG, "📍 getCurrentLocation")
                locationClient.getCurrentLocation(result)
            }

            "getLastKnownLocation" -> {
                Log.d(TAG, "📍 getLastKnownLocation")
                val loc = locationClient.getLastKnownLocation()
                if (loc != null) {
                    result.success(mapOf(
                        "latitude" to loc.latitude,
                        "longitude" to loc.longitude,
                        "accuracy" to loc.accuracy,
                        "timestamp" to loc.time,
                        "city" to (loc.city ?: "")
                    ))
                } else {
                    result.success(null)
                }
            }

            "geocodeAddress" -> {
                val address = call.argument<String>("address")
                if (address.isNullOrEmpty()) {
                    result.error("INVALID_ADDRESS", "地址不能为空", null)
                } else {
                    Log.d(TAG, "📍 geocodeAddress: $address")
                    geocodeImpl.geocodeAddress(address, result)
                }
            }

            "calculateDistance" -> {
                val fromLat = call.argument<Double>("fromLat")
                val fromLng = call.argument<Double>("fromLng")
                val toLat = call.argument<Double>("toLat")
                val toLng = call.argument<Double>("toLng")
                if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
                    result.error("INVALID_PARAMS", "坐标参数不能为空", null)
                } else {
                    val from = LatLng(fromLat, fromLng)
                    val to = LatLng(toLat, toLng)
                    val distance = AMapUtils.calculateLineDistance(from, to)
                    Log.d(TAG, "📏 calculateDistance: $from → $to = ${distance}米")
                    result.success(distance.toInt())
                }
            }

            "showRoutes" -> {
                val routesData = call.argument<List<*>>("routes")
                val selectIndex = call.argument<Int>("selectIndex") ?: 0

                Log.d(TAG, "📍 showRoutes: 自定义渲染 ${routesData?.size ?: 0} 条路线, 选中: $selectIndex")
                clearRoutePolylinesInternal()

                if (routesData.isNullOrEmpty()) {
                    result.success(0)
                    return
                }

                val aMap = aMapHolder.aMap ?: run {
                    result.success(0)
                    return
                }

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
                    result.success(routePolylines.size)
                } catch (e: Exception) {
                    Log.e(TAG, "❌ showRoutes 渲染失败: ${e.message}")
                    result.success(0)
                }
            }

            "selectRoute" -> {
                val index = call.argument<Int>("index") ?: 0
                Log.d(TAG, "📍 selectRoute: index=$index")
                highlightRouteInternal(index)
                result.success(true)
            }

            "clearRoutes" -> {
                Log.d(TAG, "📍 clearRoutes: 清除所有路线")
                clearRoutePolylinesInternal()
                result.success(true)
            }

            "setRouteMarkers" -> {
                val startLat = call.argument<Double>("startLat")
                val startLng = call.argument<Double>("startLng")
                val endLat = call.argument<Double>("endLat")
                val endLng = call.argument<Double>("endLng")
                val startLabel = call.argument<String>("startLabel") ?: "起点"
                val endLabel = call.argument<String>("endLabel") ?: "终点"
                Log.d(TAG, "📍 setRouteMarkers: start=($startLat,$startLng), end=($endLat,$endLng)")

                clearMarkersInternal()
                val aMap = aMapHolder.aMap ?: run {
                    result.success(false)
                    return
                }

                try {
                    startMarker = aMap.addMarker(MarkerOptions()
                        .position(LatLng(startLat!!, startLng!!))
                        .title(startLabel)
                        .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN)))

                    endMarker = aMap.addMarker(MarkerOptions()
                        .position(LatLng(endLat!!, endLng!!))
                        .title(endLabel)
                        .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED)))

                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "❌ setRouteMarkers 失败: ${e.message}")
                    result.success(false)
                }
            }

            "clearRouteMarkers" -> {
                Log.d(TAG, "📍 clearRouteMarkers")
                clearMarkersInternal()
                result.success(true)
            }

            "showSingleMarker" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val isStart = call.argument<Boolean>("isStart") ?: true
                val label = call.argument<String>("label") ?: (if (isStart) "起点" else "终点")
                Log.d(TAG, "📍 showSingleMarker: lat=$lat, lng=$lng, isStart=$isStart")

                if (lat == null || lng == null) {
                    result.success(false)
                    return
                }

                val aMap = aMapHolder.aMap ?: run {
                    result.success(false)
                    return
                }

                try {
                    val marker = aMap.addMarker(MarkerOptions()
                        .position(LatLng(lat, lng))
                        .title(label)
                        .icon(BitmapDescriptorFactory.defaultMarker(
                            if (isStart) BitmapDescriptorFactory.HUE_GREEN else BitmapDescriptorFactory.HUE_RED)))

                    if (isStart) {
                        startMarker?.remove()
                        startMarker = marker
                    } else {
                        endMarker?.remove()
                        endMarker = marker
                    }
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "❌ showSingleMarker 失败: ${e.message}")
                    result.success(false)
                }
            }

            "clearSingleMarker" -> {
                val isStart = call.argument<Boolean>("isStart") ?: true
                Log.d(TAG, "📍 clearSingleMarker: isStart=$isStart")
                if (isStart) {
                    startMarker?.remove()
                    startMarker = null
                } else {
                    endMarker?.remove()
                    endMarker = null
                }
                result.success(true)
            }

            "moveCamera" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val zoom = call.argument<Double>("zoom") ?: 15.0
                val bearing = call.argument<Double>("bearing")?.toFloat() ?: -1f
                val tilt = call.argument<Double>("tilt")?.toFloat() ?: -1f
                if (lat != null && lng != null) {
                    cameraController.moveCamera(lat, lng, zoom.toFloat(), bearing, tilt)
                    result.success(true)
                } else {
                    result.error("INVALID_PARAMS", "lat/lng 不能为空", null)
                }
            }

            "animateCamera" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val zoom = call.argument<Double>("zoom") ?: 15.0
                val bearing = call.argument<Double>("bearing")?.toFloat() ?: -1f
                val tilt = call.argument<Double>("tilt")?.toFloat() ?: -1f
                val duration = call.argument<Int>("duration") ?: 0
                if (lat != null && lng != null) {
                    cameraController.animateCamera(lat, lng, zoom.toFloat(), bearing, tilt, duration)
                    result.success(true)
                } else {
                    result.error("INVALID_PARAMS", "lat/lng 不能为空", null)
                }
            }

            "setPointToCenter" -> {
                val x = call.argument<Int>("x") ?: 0
                val y = call.argument<Int>("y") ?: 0
                Log.d(TAG, "🎯 setPointToCenter: x=$x, y=$y")
                cameraController.setPointToCenter(x, y)
                result.success(true)
            }

            "changeLatLng" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                if (lat != null && lng != null) {
                    Log.d(TAG, "🎥 changeLatLng (deprecated, use moveCameraToCenter): lat=$lat, lng=$lng")
                    cameraController.moveCameraToCenter(lat, lng)
                    result.success(true)
                } else {
                    result.error("INVALID_PARAMS", "lat/lng 不能为空", null)
                }
            }

            "moveCameraToCenter" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val zoom = call.argument<Double>("zoom") ?: 15.0
                if (lat != null && lng != null) {
                    cameraController.moveCameraToCenter(lat, lng, zoom.toFloat())
                    result.success(true)
                } else {
                    result.error("INVALID_PARAMS", "lat/lng 不能为空", null)
                }
            }

            "animateCameraToCenter" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val zoom = call.argument<Double>("zoom") ?: 15.0
                val duration = call.argument<Int>("duration") ?: 500
                if (lat != null && lng != null) {
                    cameraController.animateCameraToCenter(lat, lng, zoom.toFloat(), duration)
                    result.success(true)
                } else {
                    result.error("INVALID_PARAMS", "lat/lng 不能为空", null)
                }
            }

            "zoomIn" -> { cameraController.zoomIn(); result.success(true) }
            "zoomOut" -> { cameraController.zoomOut(); result.success(true) }

            "zoomTo" -> {
                val level = call.argument<Double>("level")?.toFloat() ?: 15f
                val duration = call.argument<Int>("duration") ?: 0
                cameraController.zoomTo(level, duration)
                result.success(true)
            }

            // ======== 地图图层控制 ========

            "setMapType" -> {
                val type = call.argument<Int>("type") ?: 1
                aMapHolder.aMap?.mapType = type
                Log.d(TAG, "🗺️ setMapType: $type")
                result.success(true)
            }

            "setTrafficEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                aMapHolder.aMap?.isTrafficEnabled = enabled
                Log.d(TAG, "🚦 路况图层: ${if (enabled) "显示" else "隐藏"}")
                result.success(true)
            }

            "setBuildingsEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                aMapHolder.aMap?.showBuildings(enabled)
                Log.d(TAG, "🏗️ 3D 建筑: ${if (enabled) "显示" else "隐藏"}")
                result.success(true)
            }

            "showIndoorMap" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                aMapHolder.aMap?.showIndoorMap(enabled)
                Log.d(TAG, "🏢 室内地图: ${if (enabled) "显示" else "隐藏"}")
                result.success(true)
            }

            // ======== 手势控制 ========

            "setScrollGesturesEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                aMapHolder.aMap?.uiSettings?.isScrollGesturesEnabled = enabled
                result.success(true)
            }

            "setZoomGesturesEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                aMapHolder.aMap?.uiSettings?.isZoomGesturesEnabled = enabled
                result.success(true)
            }

            "setRotateGesturesEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                aMapHolder.aMap?.uiSettings?.isRotateGesturesEnabled = enabled
                result.success(true)
            }

            "setTiltGesturesEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                aMapHolder.aMap?.uiSettings?.isTiltGesturesEnabled = enabled
                result.success(true)
            }

            // ======== 路线渲染样式 ========

            "setRouteTmcEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                Log.d(TAG, "🚦 setRouteTmcEnabled: ${if (enabled) "启用" else "禁用"} (SDK 控制)")
                // TMC 由 SDK 自动控制
                result.success(true)
            }

            "setRouteTrafficIconEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                Log.d(TAG, "🚧 setRouteTrafficIconEnabled: ${if (enabled) "启用" else "禁用"} (SDK 控制)")
                // 交通事件图标由 SDK 自动控制
                result.success(true)
            }

            // ======== 路线选中样式（支持自定义颜色/宽度） ========

            "updateSelectedRouteStyle" -> {
                Log.d(TAG, "🎨 updateSelectedRouteStyle: 样式由 SDK 控制")
                // 路线样式由 SDK 的 AMapNaviViewOptions 控制，不再支持自定义
                result.success(true)
            }

            "updateCarMarker" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val bearing = call.argument<Double>("bearing") ?: 0.0
                if (lat != null && lng != null) {
                    carOverlayRef()?.draw(
                        aMapHolder.aMap,
                        LatLng(lat, lng),
                        bearing.toFloat()
                    )
                    if (isFollowMode && isLocked) {
                        cameraController.animateCamera(lat, lng, bearing = bearing.toFloat())
                    }
                    result.success(true)
                } else {
                    result.success(false)
                }
            }

            "setFollowMode" -> {
                isFollowMode = call.argument<Boolean>("enabled") ?: false
                if (isFollowMode) {
                    isLocked = true
                } else {
                    isLocked = false
                    autoRelockHandler?.removeCallbacksAndMessages(null)
                    autoRelockHandler = null
                }
                result.success(true)
            }

            "setLockCar" -> {
                val lock = call.argument<Boolean>("locked") ?: true
                isLocked = lock
                if (!lock) {
                    autoRelockHandler?.removeCallbacksAndMessages(null)
                }
                Log.d(TAG, "🔒 锁车状态: ${if (lock) "锁定" else "解锁"}")
                result.success(true)
            }

            "clearCarMarker" -> {
                carOverlayRef()?.destroy()
                onCarOverlayDestroyed()
                result.success(true)
            }

            "setLocationDotEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                val aMap = aMapHolder.aMap
                if (aMap != null) {
                    if (enabled) {
                        // 重新设置定位样式，防止被导航 SDK 清除
                        val myLocationStyle = com.amap.api.maps.model.MyLocationStyle().apply {
                            showMyLocation(true)
                            radiusFillColor(0x301890FF.toInt())
                            strokeColor(0xFF1890FF.toInt())
                            strokeWidth(2f)
                            myLocationType(com.amap.api.maps.model.MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE)
                            interval(2000)
                        }
                        aMap.myLocationStyle = myLocationStyle
                    }
                    aMap.isMyLocationEnabled = enabled
                    Log.d(TAG, "📍 定位蓝点: ${if (enabled) "显示" else "隐藏"}")
                }
                result.success(true)
            }

            "setCarOverlayVisible" -> {
                val visible = call.argument<Boolean>("visible") ?: true
                carOverlayRef()?.setVisible(visible)
                Log.d(TAG, "📍 车载标记: ${if (visible) "显示" else "隐藏"}")
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }
}