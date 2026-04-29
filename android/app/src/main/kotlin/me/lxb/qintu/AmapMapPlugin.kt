package me.lxb.qintu

import android.content.Context
import android.util.Log
import android.view.View
import com.amap.api.maps.AMapUtils
import com.amap.api.maps.MapsInitializer
import com.amap.api.maps.model.LatLng
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import me.lxb.qintu.geocode.GeocodeImpl
import me.lxb.qintu.location.LocationClientImpl
import me.lxb.qintu.map.AMapHolder
import me.lxb.qintu.map.CameraController
import me.lxb.qintu.map.MapViewFactory
import me.lxb.qintu.route.RouteRenderer

// 类型别名，避免与 kotlin.Result 冲突
typealias Result = MethodChannel.Result

/**
 * 高德地图 PlatformView 插件
 *
 * 使用高德原生定位 SDK + 原生定位蓝点（箭头样式）
 */
class AmapMapPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "AmapMap"
        private const val VIEW_TYPE = "com.qintu/amap_map_view"
        private const val CHANNEL = "com.qintu/amap_map_control"
        private const val EVENT_CHANNEL = "com.qintu/amap_location_event"
    }

    private lateinit var channel: MethodChannel
    private var eventSink: EventChannel.EventSink? = null
    private var context: Context? = null

    // AMap 共享实例
    private val aMapHolder = AMapHolder()

    // 组件
    private lateinit var locationClient: LocationClientImpl
    private lateinit var mapViewFactory: MapViewFactory
    private var cameraController: CameraController? = null
    private var routeRenderer: RouteRenderer? = null
    private lateinit var geocodeImpl: GeocodeImpl

    // 共享状态
    private var lastKnownLocation: com.amap.api.location.AMapLocation? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        // ✅ 必须：设置高德地图隐私合规
        MapsInitializer.updatePrivacyShow(context!!, true, true)
        MapsInitializer.updatePrivacyAgree(context!!, true)

        // 初始化组件
        locationClient = LocationClientImpl(context!!)
        geocodeImpl = GeocodeImpl(context!!)
        mapViewFactory = MapViewFactory(context!!, locationClient, aMapHolder)

        // 注册 PlatformViewFactory
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            VIEW_TYPE,
            object : PlatformViewFactory(StandardMessageCodec()) {
                override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
                    return createMapView(context, viewId)
                }
            }
        )

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)

        // 注册位置事件通道
        EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )

        // 定位监听器 - 将位置传给地图，并发送首次定位事件
        locationClient.setLocationChangeListener { location ->
            lastKnownLocation = location
        }

        // 首次定位成功监听器 - 发送事件给 Flutter
        locationClient.setFirstLocationListener { location ->
            eventSink?.success(mapOf(
                "type" to "firstLocation",
                "latitude" to location.latitude,
                "longitude" to location.longitude,
                "accuracy" to location.accuracy,
                "city" to (location.city ?: "")
            ))
            Log.d(TAG, "🚀 首次定位事件已发送: ${location.latitude}, ${location.longitude}")
        }

        Log.d(TAG, "✅ AmapMapPlugin 初始化完成")
    }

    private fun createMapView(context: Context, viewId: Int): PlatformView {
        val mapView = mapViewFactory.createNativeView().apply {
            onCreate(null)
            onResume()
        }

        return object : PlatformView {
            init {
                val aMap = mapView.map
                aMapHolder.setMap(aMap)

                // 使用 MapViewFactory 配置地图
                mapViewFactory.configureMap(mapView)

                // 初始化相机控制器
                cameraController = CameraController(aMap)

                // 初始化路线渲染器
                routeRenderer = RouteRenderer(aMap)

                Log.d(TAG, "🗺️ 地图视图 #$viewId 初始化完成")
            }

            override fun getView(): View = mapView

            override fun dispose() {
                mapView.onDestroy()
                locationClient.stopLocation()
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startLocation" -> {
                Log.d(TAG, "📡 收到 startLocation 调用")
                locationClient.startLocation()
                result.success(true)
            }

            "moveToMyLocation" -> {
                Log.d(TAG, "🎯 收到 moveToMyLocation 调用")
                val lastLoc = locationClient.getLastKnownLocation()
                if (lastLoc != null) {
                    cameraController?.moveCamera(lastLoc.latitude, lastLoc.longitude)
                    result.success(true)
                } else {
                    // 尚无已知位置，通过持续定位监听的回调移动相机
                    result.success(false)
                }
            }

            "getCurrentLocation" -> {
                Log.d(TAG, "📍 收到 getCurrentLocation 调用")
                locationClient.getCurrentLocation(result)
            }

            "getLastKnownLocation" -> {
                Log.d(TAG, "📍 收到 getLastKnownLocation 调用")
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
                    Log.d(TAG, "📍 收到 geocodeAddress 调用: $address")
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
                    Log.d(TAG, "📏 计算距离: $from → $to = ${distance}米")
                    result.success(distance.toInt())
                }
            }

            "showRoutes" -> {
                val routesData = call.argument<List<*>>("routes")
                val selectIndex = call.argument<Int>("selectIndex") ?: 0
                Log.d(TAG, "📍 收到 showRoutes 调用: ${routesData?.size} 条路线, 选中: $selectIndex")

                val routes = routesData?.mapNotNull { routeData ->
                    (routeData as? List<*>)?.mapNotNull { point ->
                        (point as? Map<*, *>)?.let {
                            val lat = (it["lat"] as? Number)?.toDouble()
                            val lng = (it["lng"] as? Number)?.toDouble()
                            if (lat != null && lng != null) mapOf("lat" to lat, "lng" to lng) else null
                        }
                    }
                } ?: emptyList()

                val count = routeRenderer?.showRoutes(routes, selectIndex) ?: 0
                result.success(count)
            }

            "selectRoute" -> {
                val index = call.argument<Int>("index") ?: 0
                Log.d(TAG, "📍 收到 selectRoute 调用: index=$index")
                val success = routeRenderer?.selectRoute(index) ?: false
                result.success(success)
            }

            "clearRoutes" -> {
                Log.d(TAG, "📍 收到 clearRoutes 调用")
                routeRenderer?.clearRoutes()
                result.success(true)
            }

            "setRouteMarkers" -> {
                val startLat = call.argument<Double>("startLat")
                val startLng = call.argument<Double>("startLng")
                val endLat = call.argument<Double>("endLat")
                val endLng = call.argument<Double>("endLng")
                val startLabel = call.argument<String>("startLabel") ?: "起点"
                val endLabel = call.argument<String>("endLabel") ?: "终点"
                Log.d(TAG, "📍 收到 setRouteMarkers 调用")

                val success = routeRenderer?.setMarkers(
                    startLat, startLng, endLat, endLng, startLabel, endLabel
                ) ?: false
                result.success(success)
            }

            "clearRouteMarkers" -> {
                Log.d(TAG, "📍 收到 clearRouteMarkers 调用")
                routeRenderer?.clearMarkers()
                result.success(true)
            }

            "showSingleMarker" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val isStart = call.argument<Boolean>("isStart") ?: true
                val label = call.argument<String>("label") ?: (if (isStart) "起点" else "终点")
                Log.d(TAG, "📍 收到 showSingleMarker 调用: lat=$lat, lng=$lng, isStart=$isStart")

                val success = if (lat != null && lng != null) {
                    routeRenderer?.showSingleMarker(lat, lng, isStart, label) ?: false
                } else {
                    false
                }
                result.success(success)
            }

            "clearSingleMarker" -> {
                val isStart = call.argument<Boolean>("isStart") ?: true
                Log.d(TAG, "📍 收到 clearSingleMarker 调用: isStart=$isStart")
                routeRenderer?.clearSingleMarker(isStart)
                result.success(true)
            }

            "moveCamera" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val zoom = call.argument<Double>("zoom") ?: 15.0
                if (lat != null && lng != null) {
                    cameraController?.moveCamera(lat, lng, zoom.toFloat())
                    result.success(true)
                } else {
                    result.error("INVALID_PARAMS", "lat/lng 不能为空", null)
                }
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        locationClient.destroy()
        Log.d(TAG, "🔌 地图插件已分离")
    }
}
