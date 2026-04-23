package com.qintu.qintu

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.EventChannel.EventSink

/**
 * 高德导航插件
 * 
 * 通过 MethodChannel 和 EventChannel 实现 Flutter 与原生高德导航的通信
 * 
 * MethodChannel: 用于 Flutter 调用原生方法（开始导航、停止导航等）
 * EventChannel: 用于原生向 Flutter 推送导航状态更新
 */
class AmapNavigationPlugin : FlutterPlugin, MethodCallHandler, StreamHandler {
    
    companion object {
        private const val TAG = "AmapNavigationPlugin"
        private const val METHOD_CHANNEL = "com.qintu/amap_navigation"
        private const val EVENT_CHANNEL = "com.qintu/amap_navigation/events"
    }

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventSink? = null
    private var context: Context? = null
    
    // TODO: 后续引入高德导航 SDK
    // private var aMapNavi: AMapNavi? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "插件已附加到引擎")
        
        context = flutterPluginBinding.applicationContext
        
        // 初始化 MethodChannel
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL)
        channel.setMethodCallHandler(this)
        
        // 初始化 EventChannel
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(this)
        
        Log.d(TAG, "导航插件初始化完成")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "收到方法调用: ${call.method}")
        
        when (call.method) {
            "initialize" -> {
                handleInitialize(result)
            }
            "startNavigation" -> {
                val routePoints = call.argument<List<Map<String, Double>>>("routePoints")
                val enableVoice = call.argument<Boolean>("enableVoice") ?: true
                val enableTts = call.argument<Boolean>("enableTts") ?: true
                handleStartNavigation(routePoints, enableVoice, enableTts, result)
            }
            "stopNavigation" -> {
                handleStopNavigation(result)
            }
            "togglePause" -> {
                handleTogglePause(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * 初始化导航 SDK
     */
    private fun handleInitialize(result: Result) {
        try {
            Log.d(TAG, "初始化高德导航 SDK")
            
            // TODO: 实际初始化高德导航 SDK
            // aMapNavi = AMapNavi.getInstance(context!!)
            // aMapNavi?.addAMapNaviListener(naviListener)
            
            // 暂时返回成功（占位实现）
            result.success(true)
            Log.d(TAG, "导航 SDK 初始化成功（占位）")
        } catch (e: Exception) {
            Log.e(TAG, "导航 SDK 初始化失败", e)
            result.error("INIT_ERROR", e.message, null)
        }
    }

    /**
     * 开始导航
     */
    private fun handleStartNavigation(
        routePoints: List<Map<String, Double>>?,
        enableVoice: Boolean,
        enableTts: Boolean,
        result: Result
    ) {
        try {
            if (routePoints == null || routePoints.size < 2) {
                Log.w(TAG, "路线点数不足")
                result.error("INVALID_ROUTE", "路线点数不足，至少需要 2 个点", null)
                return
            }

            Log.d(TAG, "开始导航，路线点数: ${routePoints.size}")
            Log.d(TAG, "语音播报: $enableVoice, TTS: $enableTts")
            
            // 打印路线点（调试用）
            routePoints.forEachIndexed { index, point ->
                Log.d(TAG, "点 $index: lat=${point["latitude"]}, lng=${point["longitude"]}")
            }
            
            // TODO: 实际调用高德导航 SDK
            // 1. 构建路线点
            // 2. 计算路线
            // 3. 开始导航
            // 4. 开启语音播报
            
            // 暂时返回成功（占位实现）
            result.success(true)
            Log.d(TAG, "导航已开始（占位）")
            
            // 模拟发送导航状态更新
            simulateNavigationUpdates()
        } catch (e: Exception) {
            Log.e(TAG, "开始导航失败", e)
            result.error("NAVIGATION_ERROR", e.message, null)
        }
    }

    /**
     * 停止导航
     */
    private fun handleStopNavigation(result: Result) {
        try {
            Log.d(TAG, "停止导航")
            
            // TODO: 实际调用高德导航 SDK
            // aMapNavi?.stopNavi()
            
            result.success(true)
            Log.d(TAG, "导航已停止（占位）")
        } catch (e: Exception) {
            Log.e(TAG, "停止导航失败", e)
            result.error("STOP_ERROR", e.message, null)
        }
    }

    /**
     * 切换暂停/继续
     */
    private fun handleTogglePause(result: Result) {
        try {
            Log.d(TAG, "切换导航暂停/继续状态")
            
            // TODO: 实际调用高德导航 SDK
            
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "切换暂停状态失败", e)
            result.error("TOGGLE_ERROR", e.message, null)
        }
    }

    /**
     * 模拟导航状态更新（测试用）
     */
    private fun simulateNavigationUpdates() {
        // TODO: 替换为真实的导航状态推送
        
        val state = mapOf(
            "status" to "navigating",
            "currentSpeed" to 60.0,
            "remainingDistance" to 5000,
            "remainingDuration" to 600,
            "nextInstruction" to "前方 500 米右转",
            "currentLat" to 39.9042,
            "currentLng" to 116.4074,
            "roadName" to "长安街"
        )
        
        eventSink?.success(state)
        Log.d(TAG, "发送模拟导航状态: $state")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "插件已从引擎分离")
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }

    // ==================== EventChannel StreamHandler ====================

    override fun onListen(arguments: Any?, events: EventSink?) {
        Log.d(TAG, "开始监听导航状态")
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "取消监听导航状态")
        eventSink = null
    }
}
