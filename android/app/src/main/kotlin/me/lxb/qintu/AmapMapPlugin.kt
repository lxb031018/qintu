package me.lxb.qintu

import android.app.Activity
import android.content.Context
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.view.ViewTreeObserver
import com.amap.api.navi.AMapNaviView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
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
import me.lxb.qintu.map.MarkerManager
import me.lxb.qintu.map.NaviViewFactory
import me.lxb.qintu.map.RouteRenderer
import me.lxb.qintu.map.GestureHandler
import me.lxb.qintu.overlay.CarOverlay

import me.lxb.qintu.util.AMapPrivacy
import com.amap.api.location.AMapLocation

// 类型别名，避免与 kotlin.Result 冲突
typealias Result = MethodChannel.Result

/**
 * 高德地图 PlatformView 插件（Plugin 层）
 *
 * 仅负责 Flutter 通信，不含业务逻辑。
 * 业务逻辑委托给 MapController（功能模块层）。
 */
class AmapMapPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    companion object {
        private const val TAG = "AmapMap"
    }

    private lateinit var channel: MethodChannel
    private var eventSink: EventChannel.EventSink? = null
    private var context: Context? = null
    private var activity: Activity? = null

    // AMap 共享实例
    private val aMapHolder = AMapHolder()

    // 组件
    private lateinit var locationClient: LocationClientImpl
    private lateinit var naviViewFactory: NaviViewFactory
    private var cameraController: CameraController? = null
    
    private var carOverlay: CarOverlay? = null
    private var geocodeImpl: GeocodeImpl? = null

    // 业务控制器（功能模块层）
    private var mapController: MapController? = null

    // 当前激活的 AMapNaviView 实例（用于生命周期管理）
    private var currentNaviView: AMapNaviView? = null

    // 首次定位是否已触发（等待视图就绪后再发送）
    private var firstLocationPending: AMapLocation? = null

    // 定位蓝点是否已启用（延迟到首次 setPointToCenter 后开启）
    private var myLocationEnabled = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        // 设置高德地图隐私合规
        AMapPrivacy.initMap(context!!)

        // 初始化组件
        locationClient = LocationClientImpl(context!!)
        geocodeImpl = GeocodeImpl(context!!)
        naviViewFactory = NaviViewFactory(context!!, locationClient, aMapHolder)

        // 注册 PlatformViewFactory
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            PlatformChannels.NAVI_VIEW,
            object : PlatformViewFactory(StandardMessageCodec()) {
                override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
                    return createNaviView(context, viewId)
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

        // 首次定位成功监听器 - 等待视图就绪后再发送
        locationClient.setFirstLocationListener { location ->
            if (cameraController?.isViewSizeReady() == true) {
                eventSink?.success(mapOf(
                    "type" to "firstLocation",
                    "latitude" to location.latitude,
                    "longitude" to location.longitude,
                    "accuracy" to location.accuracy,
                    "city" to (location.city ?: "")
                ))
                Log.d(TAG, "🚀 首次定位事件已发送: ${location.latitude}, ${location.longitude}")
            } else {
                firstLocationPending = location
                Log.d(TAG, "⏳ 首次定位事件暂存，等待视图就绪: ${location.latitude}, ${location.longitude}")
            }
        }

        Log.d(TAG, "✅ AmapMapPlugin 初始化完成")
    }

    private fun createNaviView(context: Context, viewId: Int): PlatformView {
        val naviView = naviViewFactory.createNativeView().apply {
            onCreate(null)
            onResume()
        }
        currentNaviView = naviView

        // 设置退出导航监听器，将事件发送到 Flutter
        naviViewFactory.onNaviViewExitListener = {
            Log.d(TAG, "🚪 导航退出事件，发送到 Flutter")
            eventSink?.success(mapOf("type" to "naviViewExit"))
        }

        // 设置导航视图加载完成回调，通知 RouteRenderer 可以渲染路线
        naviViewFactory.onNaviViewLoadedCallback = {
            mapController?.onNaviViewLoaded()
        }

        Log.d(TAG, "📍 createNaviView 完成")

        return object : PlatformView {
            init {
                val aMap = naviView.map
                aMapHolder.setMap(aMap)

                // 使用 NaviViewFactory 配置地图
                naviViewFactory.configureMap(naviView)

                // 初始化功能模块组件
                cameraController = CameraController(aMap)

                // 初始化子模块
                val routeRenderer = RouteRenderer(aMapHolder, { currentNaviView })
                val markerManager = MarkerManager(aMapHolder)
                val gestureHandler = GestureHandler(
                    cameraController!!,
                    { carOverlay },
                    aMapHolder,
                    { }  // onMapGestureDetected - 在 Plugin 层处理
                )

                // 初始化业务控制器
                mapController = MapController(
                    locationClient = locationClient,
                    geocodeImpl = geocodeImpl!!,
                    cameraController = cameraController!!,
                    aMapHolder = aMapHolder,
                    carOverlayRef = { carOverlay },
                    onCarOverlayDestroyed = { carOverlay = null },
                    routeRenderer = routeRenderer,
                    markerManager = markerManager,
                    gestureHandler = gestureHandler
                )
                // 触摸监听：检测地图手势 → 解锁车辆 → 安排自动重新锁定
                aMap.setOnMapTouchListener { motionEvent ->
                    if (motionEvent.action == MotionEvent.ACTION_UP) {
                        mapController?.onMapTouched()
                    }
                }

                // 保存视图尺寸，供 CameraController 在 moveCameraToCenter 时使用
                // 同时修复 AMapNaviView 内部预留空间导致的地图中心偏移问题
                // 注意：不移除监听器，因为 setNaviShowMode 可能重置中心点，每次布局变化都需要重设
                naviView.viewTreeObserver.addOnGlobalLayoutListener(
                    object : ViewTreeObserver.OnGlobalLayoutListener {
                        override fun onGlobalLayout() {
                            if (naviView.width > 0 && naviView.height > 0) {
                                val centerX = naviView.width / 2
                                val centerY = naviView.height / 2
                                cameraController?.setViewSize(naviView.width, naviView.height)
                                naviView.map.setPointToCenter(centerX, centerY)

                                // 首次布局完成后才启用定位蓝点，确保地图中心已被修正
                                if (!myLocationEnabled) {
                                    myLocationEnabled = true
                                    naviView.map.isMyLocationEnabled = true
                                    Log.d(TAG, "🔵 首次布局完成，中心已修正，启用定位蓝点")
                                }

                                Log.d(TAG, "🎯 地图中心已修正: (${centerX}, ${centerY}), size=(${naviView.width}x${naviView.height})")

                                firstLocationPending?.let { location ->
                                    eventSink?.success(mapOf(
                                        "type" to "firstLocation",
                                        "latitude" to location.latitude,
                                        "longitude" to location.longitude,
                                        "accuracy" to location.accuracy,
                                        "city" to (location.city ?: "")
                                    ))
                                    firstLocationPending = null
                                    Log.d(TAG, "🚀 暂存的首次定位事件已发送: ${location.latitude}, ${location.longitude}")
                                }
                            }
                        }
                    }
                )

                Log.d(TAG, "🗺️ AMapNaviView #$viewId 初始化完成")
            }

            override fun getView(): View = naviView

            override fun dispose() {
                naviView.onPause()
                naviView.onDestroy()
                currentNaviView = null
                locationClient.stopLocation()
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "pauseNaviView" -> {
                currentNaviView?.onPause()
                result.success(true)
            }
            "resumeNaviView" -> {
                currentNaviView?.onResume()
                result.success(true)
            }
            "setNaviShowMode" -> {
                val mode = call.argument<Int>("mode") ?: 3
                currentNaviView?.setShowMode(mode)
                result.success(true)
            }
            "enableNaviMode" -> {
                currentNaviView?.let { naviViewFactory.enableNaviMode(it) }
                result.success(true)
            }
            "disableNaviMode" -> {
                currentNaviView?.let { naviViewFactory.disableNaviMode(it) }
                result.success(true)
            }
            else -> mapController?.handleMethodCall(call, result) ?: result.notImplemented()
        }
    }

    // ==================== ActivityAware ====================

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d(TAG, "已绑定 Activity")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        locationClient.destroy()
        Log.d(TAG, "🔌 地图插件已分离")
    }
}