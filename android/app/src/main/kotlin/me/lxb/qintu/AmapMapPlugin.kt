package me.lxb.qintu

import android.app.Activity
import android.content.Context
import android.util.Log
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
import me.lxb.qintu.map.MapController
import me.lxb.qintu.map.NaviViewFactory
import me.lxb.qintu.overlay.CarOverlay

import me.lxb.qintu.util.AMapPrivacy

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
    private var geocodeImpl: GeocodeImpl? = null

    private var carOverlay: CarOverlay? = null
    private var isNavigating = false

    // 业务控制器（功能模块层）
    private var mapController: MapController? = null

    // 当前激活的 AMapNaviView 实例（用于生命周期管理）
    private var currentNaviView: AMapNaviView? = null

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

        // 定位监听器 — 更新车载标记（仅导航激活时创建）
        locationClient.setLocationChangeListener { location ->
            // 仅在导航激活时懒初始化 CarOverlay，防止退出导航后重建
            if (isNavigating && carOverlay == null && context != null) {
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
            val factory = naviViewFactory
            if (factory.onFirstLocationReady != null) {
                factory.onFirstLocationReady?.invoke(
                    location.latitude,
                    location.longitude,
                    location.accuracy.toDouble(),
                    location.city ?: ""
                )
                Log.d(TAG, "🚀 首次定位事件已发送: ${location.latitude}, ${location.longitude}")
            } else {
                factory.setPendingFirstLocation(location)
                Log.d(TAG, "⏳ 首次定位事件暂存，等待视图就绪: ${location.latitude}, ${location.longitude}")
            }
        }

        Log.d(TAG, "✅ AmapMapPlugin 初始化完成")
    }

    private fun createNaviView(context: Context, viewId: Int): PlatformView {
        // 设置导航退出回调
        naviViewFactory.onNaviViewExitListener = {
            Log.d(TAG, "🚪 导航退出事件，发送到 Flutter")
            eventSink?.success(mapOf("type" to "naviViewExit"))
        }

        val result = naviViewFactory.createPlatformView(
            viewId = viewId,
            carOverlayRef = { carOverlay },
            currentNaviViewRef = { currentNaviView },
            onMapTouched = { mapController?.onMapTouched() }
        )

        currentNaviView = result.naviView

        // 初始化业务控制器
        mapController = MapController(
            locationClient = locationClient,
            geocodeImpl = geocodeImpl!!,
            cameraController = result.mapComponents.cameraController,
            aMapHolder = aMapHolder,
            carOverlayRef = { carOverlay },
            onCarOverlayDestroyed = { carOverlay = null },
            routeRenderer = result.mapComponents.routeRenderer,
            markerManager = result.mapComponents.markerManager,
            gestureHandler = result.mapComponents.gestureHandler
        )

        naviViewFactory.onNaviViewLoadedCallback = {
            mapController?.onNaviViewLoaded()
        }

        Log.d(TAG, "📍 createNaviView 完成")

        // 注册首次定位就绪回调
        naviViewFactory.onFirstLocationReady = { lat, lng, accuracy, city ->
            eventSink?.success(mapOf(
                "type" to "firstLocation",
                "latitude" to lat,
                "longitude" to lng,
                "accuracy" to accuracy,
                "city" to city
            ))
        }

        return result.platformView
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
                isNavigating = true
                currentNaviView?.let { naviViewFactory.enableNaviMode(it) }
                result.success(true)
            }
            "disableNaviMode" -> {
                isNavigating = false
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