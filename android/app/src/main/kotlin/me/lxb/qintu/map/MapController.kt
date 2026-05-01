package me.lxb.qintu.map

import android.util.Log
import com.amap.api.maps.AMapUtils
import com.amap.api.maps.model.LatLng
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import me.lxb.qintu.geocode.GeocodeImpl
import me.lxb.qintu.location.LocationClientImpl
import me.lxb.qintu.map.AMapHolder
import me.lxb.qintu.overlay.CarOverlay
import me.lxb.qintu.route.RoutePathCache
import me.lxb.qintu.route.RouteRenderer

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
    private val routeRenderer: RouteRenderer,
    private val cameraController: CameraController,
    private val aMapHolder: AMapHolder,
    private val carOverlayRef: () -> CarOverlay?,
    private val onCarOverlayDestroyed: () -> Unit,
    var isFollowMode: Boolean = false
) {
    companion object {
        private const val TAG = "MapController"
    }

    /**
     * 处理来自定位监听器的位置更新，驱动 CarOverlay 自车标记绘制
     */
    fun onLocationChanged(lat: Double, lng: Double, bearing: Float) {
        carOverlayRef()?.draw(aMapHolder.aMap, LatLng(lat, lng), bearing)
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
                    cameraController.moveCamera(lastLoc.latitude, lastLoc.longitude)
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
                val routeIds = call.argument<List<*>>("routeIds")?.mapNotNull {
                    (it as? Number)?.toInt()
                }
                val colors = call.argument<List<*>>("colors")?.mapNotNull {
                    (it as? Number)?.toInt()
                }
                val widths = call.argument<List<*>>("widths")?.mapNotNull {
                    (it as? Number)?.toDouble()
                }
                val dashedFlags = call.argument<List<*>>("dashedFlags")?.mapNotNull {
                    it as? Boolean
                }

                // 优先用 RouteOverLay（与导航样式一致，带方向箭头）
                if (routeIds != null && routeIds.isNotEmpty() && RoutePathCache.size() > 0) {
                    val paths = routeIds.mapNotNull { RoutePathCache.get(it) }
                    if (paths.isNotEmpty()) {
                        Log.d(TAG, "📍 showRoutes: RouteOverLay ${paths.size} 条路线, 选中: $selectIndex")
                        val count = routeRenderer.showRouteOverlays(paths, selectIndex)
                        result.success(count)
                        return
                    }
                }

                // 回退到 Polyline 渲染
                Log.d(TAG, "📍 showRoutes: Polyline ${routesData?.size} 条路线, 选中: $selectIndex, colors=${colors?.size}, widths=${widths?.size}")
                val routes = routesData?.mapNotNull { routeData ->
                    (routeData as? List<*>)?.mapNotNull { point ->
                        (point as? Map<*, *>)?.let {
                            val lat = (it["lat"] as? Number)?.toDouble()
                            val lng = (it["lng"] as? Number)?.toDouble()
                            if (lat != null && lng != null) mapOf("lat" to lat, "lng" to lng) else null
                        }
                    }
                } ?: emptyList()

                val count = routeRenderer.showRoutes(routes, selectIndex, colors, widths, dashedFlags)
                result.success(count)
            }

            "selectRoute" -> {
                val index = call.argument<Int>("index") ?: 0
                Log.d(TAG, "📍 selectRoute: index=$index")
                val success = routeRenderer.selectRoute(index)
                result.success(success)
            }

            "enterNavigationMode" -> {
                val routeId = call.argument<Int>("routeId") ?: 0
                Log.d(TAG, "🚗 enterNavigationMode: routeId=$routeId")
                val success = routeRenderer.showNavigateRoute(routeId)
                result.success(success)
            }

            "clearRoutes" -> {
                Log.d(TAG, "📍 clearRoutes")
                routeRenderer.clearRoutes()
                result.success(true)
            }

            "setRouteMarkers" -> {
                val startLat = call.argument<Double>("startLat")
                val startLng = call.argument<Double>("startLng")
                val endLat = call.argument<Double>("endLat")
                val endLng = call.argument<Double>("endLng")
                val startLabel = call.argument<String>("startLabel") ?: "起点"
                val endLabel = call.argument<String>("endLabel") ?: "终点"
                Log.d(TAG, "📍 setRouteMarkers")

                val success = routeRenderer.setMarkers(
                    startLat, startLng, endLat, endLng, startLabel, endLabel
                )
                result.success(success)
            }

            "clearRouteMarkers" -> {
                Log.d(TAG, "📍 clearRouteMarkers")
                routeRenderer.clearMarkers()
                result.success(true)
            }

            "showSingleMarker" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val isStart = call.argument<Boolean>("isStart") ?: true
                val label = call.argument<String>("label") ?: (if (isStart) "起点" else "终点")
                Log.d(TAG, "📍 showSingleMarker: lat=$lat, lng=$lng, isStart=$isStart")

                val success = if (lat != null && lng != null) {
                    routeRenderer.showSingleMarker(lat, lng, isStart, label)
                } else {
                    false
                }
                result.success(success)
            }

            "clearSingleMarker" -> {
                val isStart = call.argument<Boolean>("isStart") ?: true
                Log.d(TAG, "📍 clearSingleMarker: isStart=$isStart")
                routeRenderer.clearSingleMarker(isStart)
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
                routeRenderer.setTmcEnabled(enabled)
                result.success(true)
            }

            "setRouteTrafficIconEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                routeRenderer.setTrafficIconEnabled(enabled)
                result.success(true)
            }

            // ======== 路线选中样式（支持自定义颜色/宽度） ========

            "updateSelectedRouteStyle" -> {
                val selectedColor = call.argument<Long>("selectedColor")?.toInt()
                val unselectedColor = call.argument<Long>("unselectedColor")?.toInt()
                val selectedWidth = call.argument<Double>("selectedWidth")?.toFloat()
                val unselectedWidth = call.argument<Double>("unselectedWidth")?.toFloat()
                routeRenderer.updateRouteStyle(
                    selectedColor = selectedColor,
                    unselectedColor = unselectedColor,
                    selectedWidth = selectedWidth,
                    unselectedWidth = unselectedWidth
                )
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
                    if (isFollowMode) {
                        cameraController.animateCamera(lat, lng)
                    }
                    result.success(true)
                } else {
                    result.success(false)
                }
            }

            "setFollowMode" -> {
                isFollowMode = call.argument<Boolean>("enabled") ?: false
                result.success(true)
            }

            "clearCarMarker" -> {
                carOverlayRef()?.destroy()
                onCarOverlayDestroyed()
                result.success(true)
            }

            "setLocationDotEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                aMapHolder.aMap?.isMyLocationEnabled = enabled
                Log.d(TAG, "📍 定位蓝点: ${if (enabled) "显示" else "隐藏"}")
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