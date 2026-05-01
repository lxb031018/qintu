package me.lxb.qintu

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import me.lxb.qintu.constant.PlatformChannels
import me.lxb.qintu.navigation.NavigationImpl

/**
 * 高德 Android 导航 SDK 桥接插件（Plugin 层）
 *
 * 仅负责 Flutter 通信，不含业务逻辑。
 * 业务逻辑委托给 NavigationImpl（功能模块层）。
 */
class AmapNavigationPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        private const val TAG = "AmapNavigation"
    }

    private lateinit var channel: MethodChannel
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private var context: Context? = null
    private var navigationImpl: NavigationImpl? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, PlatformChannels.NAVIGATION)
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, PlatformChannels.NAVIGATION_EVENTS)
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        // 初始化功能模块
        navigationImpl = NavigationImpl(context!!)
        navigationImpl?.eventListener = { event -> eventSink?.success(event) }

        Log.d(TAG, "导航插件已注册")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val impl = navigationImpl
        if (impl == null) {
            result.error("NOT_READY", "导航模块未初始化", null)
            return
        }

        when (call.method) {
            "initialize" -> impl.initialize(result)

            "calculateRoute" -> {
                val routeType = call.argument<String>("routeType") ?: "driving"
                val fromLat = call.argument<Double>("fromLat") ?: run { result.error("INVALID_PARAMS", "fromLat 缺失", null); return }
                val fromLng = call.argument<Double>("fromLng") ?: run { result.error("INVALID_PARAMS", "fromLng 缺失", null); return }
                val toLat = call.argument<Double>("toLat") ?: run { result.error("INVALID_PARAMS", "toLat 缺失", null); return }
                val toLng = call.argument<Double>("toLng") ?: run { result.error("INVALID_PARAMS", "toLng 缺失", null); return }
                val strategy = call.argument<Int>("strategy") ?: 0
                val multiRoute = call.argument<Boolean>("multiRoute") ?: true
                impl.calculateRoute(routeType, fromLat, fromLng, toLat, toLng, strategy, multiRoute, result)
            }

            "selectRouteId" -> {
                val routeId = call.argument<Int>("routeId") ?: 0
                impl.selectRouteId(routeId)
                result.success(true)
            }

            "startNavigation" -> {
                val isEmulator = call.argument<Boolean>("isEmulator") ?: false
                val enableVoice = call.argument<Boolean>("enableVoice") ?: true
                impl.startNavigation(isEmulator, enableVoice, result)
            }

            "stopNavigation" -> impl.stopNavi(result)

            "togglePause" -> impl.pauseNavi(result)

            else -> result.notImplemented()
        }
    }

    // ==================== ActivityAware ====================

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "已绑定 Activity")
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        navigationImpl?.destroy()
        navigationImpl = null
        Log.d(TAG, "导航插件已分离")
    }
}
