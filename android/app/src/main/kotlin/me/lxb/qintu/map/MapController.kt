package me.lxb.qintu.map

import android.util.Log
import com.amap.api.maps.AMapUtils
import com.amap.api.maps.model.LatLng
import com.amap.api.navi.AMapNaviView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import me.lxb.qintu.geocode.GeocodeImpl
import me.lxb.qintu.location.LocationClientImpl
import me.lxb.qintu.map.AMapHolder
import me.lxb.qintu.overlay.CarOverlay

/**
 * 地图业务控制器（协调层）
 *
 * 职责：
 * - MethodCall 路由分发
 * - 协调 RouteRenderer、MarkerManager、GestureHandler
 * - 不直接处理渲染逻辑
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
    routeRenderer: RouteRenderer,
    markerManager: MarkerManager,
    gestureHandler: GestureHandler
) {
    companion object {
        private const val TAG = "MapController"
    }

    // 子模块
    private val routeRenderer = routeRenderer
    private val markerManager = markerManager
    private val gestureHandler = gestureHandler

    fun setNaviView(view: AMapNaviView?) {
        routeRenderer.setNaviView(view)
    }

    /**
     * 处理来自定位监听器的位置更新，驱动 CarOverlay 自车标记绘制
     */
    fun onLocationChanged(lat: Double, lng: Double, bearing: Float) {
        gestureHandler.updateCarMarkerForLocation(lat, lng, bearing)
    }

    /**
     * 用户触摸地图时调用：解锁相机并安排 6 秒后自动重新锁定
     */
    fun onMapTouched() {
        gestureHandler.onMapTouched()
    }

    /**
     * 处理来自 Plugin 层的 MethodCall
     */
    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // ======== 定位 ========
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

            // ======== 地理编码 ========
            "geocodeAddress" -> {
                val address = call.argument<String>("address")
                if (address.isNullOrEmpty()) {
                    result.error("INVALID_ADDRESS", "地址不能为空", null)
                } else {
                    Log.d(TAG, "📍 geocodeAddress: $address")
                    geocodeImpl.geocodeAddress(address, result)
                }
            }

            // ======== 距离计算 ========
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

            // ======== 路线渲染（自定义 Polyline） ========
            "showRoutes" -> {
                val routesData = call.argument<List<*>>("routes")
                val selectIndex = call.argument<Int>("selectIndex") ?: 0
                Log.d(TAG, "📍 showRoutes: 自定义渲染 ${routesData?.size ?: 0} 条路线, 选中: $selectIndex")
                val count = routeRenderer.showRoutes(routesData, selectIndex)
                result.success(count)
            }

            "selectRoute" -> {
                val index = call.argument<Int>("index") ?: 0
                Log.d(TAG, "📍 selectRoute: index=$index")
                routeRenderer.selectRoute(index)
                result.success(true)
            }

            "clearRoutes" -> {
                Log.d(TAG, "📍 clearRoutes: 清除所有路线")
                routeRenderer.clearRoutes()
                result.success(true)
            }

            // ======== 路线渲染（SDK RouteOverLay） ========
            "showRoutesWithOverlay" -> {
                val routeIds = call.argument<List<Int>>("routeIds") ?: emptyList()
                val selectIndex = call.argument<Int>("selectIndex") ?: 0
                Log.d(TAG, "📍 showRoutesWithOverlay: routeIds=${routeIds.size}, selectIndex=$selectIndex")
                val count = routeRenderer.showRoutesWithOverlay(routeIds, selectIndex)
                result.success(count)
            }

            "highlightRouteOverlay" -> {
                val routeId = call.argument<Int>("routeId") ?: -1
                Log.d(TAG, "📍 highlightRouteOverlay: routeId=$routeId")
                routeRenderer.highlightRoute(routeId)
                result.success(true)
            }

            "clearRouteOverlays" -> {
                Log.d(TAG, "📍 clearRouteOverlays")
                routeRenderer.clearRouteOverlays()
                result.success(true)
            }

            // ======== 标记管理 ========
            "setRouteMarkers" -> {
                val startLat = call.argument<Double>("startLat")
                val startLng = call.argument<Double>("startLng")
                val endLat = call.argument<Double>("endLat")
                val endLng = call.argument<Double>("endLng")
                val startLabel = call.argument<String>("startLabel") ?: "起点"
                val endLabel = call.argument<String>("endLabel") ?: "终点"
                Log.d(TAG, "📍 setRouteMarkers: start=($startLat,$startLng), end=($endLat,$endLng)")

                if (startLat == null || startLng == null || endLat == null || endLng == null) {
                    result.success(false)
                    return
                }
                val success = markerManager.setRouteMarkers(startLat, startLng, endLat, endLng, startLabel, endLabel)
                result.success(success)
            }

            "clearRouteMarkers" -> {
                Log.d(TAG, "📍 clearRouteMarkers")
                markerManager.clearRouteMarkers()
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
                val success = markerManager.showSingleMarker(lat, lng, isStart, label)
                result.success(success)
            }

            "clearSingleMarker" -> {
                val isStart = call.argument<Boolean>("isStart") ?: true
                Log.d(TAG, "📍 clearSingleMarker: isStart=$isStart")
                markerManager.clearSingleMarker(isStart)
                result.success(true)
            }

            // ======== 相机控制 ========
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

            // ======== 路线渲染样式（已废弃，保留接口兼容性）=======
            "setRouteTmcEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                Log.d(TAG, "🚦 setRouteTmcEnabled: ${if (enabled) "启用" else "禁用"} (SDK 控制)")
                result.success(true)
            }

            "setRouteTrafficIconEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                Log.d(TAG, "🚧 setRouteTrafficIconEnabled: ${if (enabled) "启用" else "禁用"} (SDK 控制)")
                result.success(true)
            }

            "updateSelectedRouteStyle" -> {
                Log.d(TAG, "🎨 updateSelectedRouteStyle: 样式由 SDK 控制")
                result.success(true)
            }

            // ======== 车辆与跟随模式 ========
            "updateCarMarker" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val bearing = call.argument<Double>("bearing") ?: 0.0
                if (lat != null && lng != null) {
                    gestureHandler.updateCarMarker(lat, lng, bearing)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }

            "setFollowMode" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                gestureHandler.setFollowMode(enabled)
                result.success(true)
            }

            "setLockCar" -> {
                val lock = call.argument<Boolean>("locked") ?: true
                gestureHandler.setLockCar(lock)
                result.success(true)
            }

            "clearCarMarker" -> {
                gestureHandler.clearCarMarker(onCarOverlayDestroyed)
                result.success(true)
            }

            "setLocationDotEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                gestureHandler.setLocationDotEnabled(enabled)
                result.success(true)
            }

            "setCarOverlayVisible" -> {
                val visible = call.argument<Boolean>("visible") ?: true
                gestureHandler.setCarOverlayVisible(visible)
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }
}