package me.lxb.qintu

import android.content.Context
import android.util.Log
import android.view.MotionEvent
import android.view.View
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import me.lxb.qintu.constant.PlatformChannels
import me.lxb.qintu.geocode.GeocodeImpl
import me.lxb.qintu.location.LocationClientImpl
import me.lxb.qintu.map.AMapHolder
import me.lxb.qintu.map.CameraController
import me.lxb.qintu.map.MapController
import me.lxb.qintu.map.MapViewFactory
import me.lxb.qintu.overlay.CarOverlay
import me.lxb.qintu.route.RouteRenderer
import me.lxb.qintu.util.AMapPrivacy

// 类型别名，避免与 kotlin.Result 冲突
typealias Result = MethodChannel.Result

/**
 * 高德地图 PlatformView 插件（Plugin 层）
 *
 * 仅负责 Flutter 通信，不含业务逻辑。
 * 业务逻辑委托给 MapController（功能模块层）。
 */
class AmapMapPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "AmapMap"
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
    private var carOverlay: CarOverlay? = null
    private var geocodeImpl: GeocodeImpl? = null

    // 业务控制器（功能模块层）
    private var mapController: MapController? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        // 设置高德地图隐私合规
        AMapPrivacy.initMap(context!!)

        // 初始化组件
        locationClient = LocationClientImpl(context!!)
        geocodeImpl = GeocodeImpl(context!!)
        mapViewFactory = MapViewFactory(context!!, locationClient, aMapHolder)

        // 注册 PlatformViewFactory
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            PlatformChannels.MAP_VIEW,
            object : PlatformViewFactory(StandardMessageCodec()) {
                override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
                    return createMapView(context, viewId)
                }
            }
        )

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, PlatformChannels.MAP_CONTROL)
        channel.setMethodCallHandler(this)

        // 注册位置事件通道
        EventChannel(flutterPluginBinding.binaryMessenger, PlatformChannels.MAP_LOCATION_EVENT).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )

        // 定位监听器 — 更新车载标记（仅导航时显示）
        locationClient.setLocationChangeListener { location ->
            // 懒初始化 CarOverlay（资源初始化，非业务逻辑）
            if (carOverlay == null && context != null) {
                carOverlay = CarOverlay(context!!).apply {
                    setDirectionVisible(false)
                    setVisible(false)
                }
            }
            // 委托给 MapController 处理位置更新业务
            mapController?.onLocationChanged(
                location.latitude, location.longitude, location.bearing
            )
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

                // 初始化功能模块组件
                cameraController = CameraController(aMap)
                routeRenderer = RouteRenderer(aMap, context)

                // 初始化业务控制器
                mapController = MapController(
                    locationClient = locationClient,
                    geocodeImpl = geocodeImpl!!,
                    routeRenderer = routeRenderer!!,
                    cameraController = cameraController!!,
                    aMapHolder = aMapHolder,
                    carOverlayRef = { carOverlay },
                    onCarOverlayDestroyed = { carOverlay = null }
                )

                // 触摸监听：检测地图手势 → 解锁车辆 → 安排自动重新锁定
                aMap.setOnMapTouchListener { motionEvent ->
                    if (motionEvent.action == MotionEvent.ACTION_UP) {
                        mapController?.onMapTouched()
                    }
                }

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
        mapController?.handleMethodCall(call, result) ?: result.notImplemented()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        locationClient.destroy()
        Log.d(TAG, "🔌 地图插件已分离")
    }
}