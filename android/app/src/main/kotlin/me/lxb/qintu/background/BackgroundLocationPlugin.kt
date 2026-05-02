package me.lxb.qintu.background

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import me.lxb.qintu.constant.PlatformChannels

/**
 * 后台定位插件（Plugin 层）
 *
 * 仅负责 Flutter 通信，不含业务逻辑。
 * MethodChannel 处理 start/stop/isRunning 命令，
 * EventChannel 向后台上报定位数据。
 */
class BackgroundLocationPlugin : FlutterPlugin, MethodCallHandler {

    companion object {
        private const val TAG = "BgLocationPlugin"
    }

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private var context: Context? = null

    private var serviceBound = false
    private var backgroundService: BackgroundLocationService? = null

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as? BackgroundLocationService.LocalBinder
            if (binder == null) {
                Log.e(TAG, "绑定失败：Binder 类型不匹配")
                return
            }
            backgroundService = binder.getService()
            serviceBound = true
            backgroundService?.registerCallback(object : BackgroundLocationService.LocationCallback {
                override fun onLocationResult(location: com.amap.api.location.AMapLocation) {
                    eventSink?.success(
                        mapOf(
                            "latitude" to location.latitude,
                            "longitude" to location.longitude,
                            "accuracy" to location.accuracy,
                            "speed" to location.speed,
                            "bearing" to location.bearing,
                            "timestamp" to location.time,
                            "city" to (location.city ?: ""),
                            "provider" to (location.provider ?: ""),
                        )
                    )
                }

                override fun onError(errorCode: Int, errorInfo: String) {
                    eventSink?.error("LOCATION_ERROR", "错误 $errorCode: $errorInfo", null)
                }
            })
            Log.d(TAG, "后台定位服务已绑定")
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            serviceBound = false
            backgroundService = null
            Log.d(TAG, "后台定位服务连接已断开")
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, PlatformChannels.BACKGROUND_LOCATION)
        methodChannel?.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, PlatformChannels.BACKGROUND_LOCATION_EVENTS)
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        Log.d(TAG, "后台定位插件已注册")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "start" -> startBackgroundLocation(result)
            "stop" -> stopBackgroundLocation(result)
            "isRunning" -> result.success(serviceBound)
            else -> result.notImplemented()
        }
    }

    private fun startBackgroundLocation(result: Result) {
        val ctx = context
        if (ctx == null) {
            result.error("NO_CONTEXT", "Context 不可用", null)
            return
        }

        try {
            val intent = Intent(ctx, BackgroundLocationService::class.java)
            ctx.startService(intent)

            if (!serviceBound) {
                ctx.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
            }

            Log.d(TAG, "后台定位服务启动中")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "启动后台定位服务失败", e)
            result.error("START_FAILED", e.message, null)
        }
    }

    private fun stopBackgroundLocation(result: Result) {
        val ctx = context
        if (ctx == null) {
            result.error("NO_CONTEXT", "Context 不可用", null)
            return
        }

        try {
            backgroundService?.unregisterCallback()

            if (serviceBound) {
                ctx.unbindService(serviceConnection)
                serviceBound = false
            }

            val intent = Intent(ctx, BackgroundLocationService::class.java)
            ctx.stopService(intent)

            backgroundService = null
            Log.d(TAG, "后台定位服务已停止")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "停止后台定位服务失败", e)
            result.error("STOP_FAILED", e.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        backgroundService?.unregisterCallback()

        if (serviceBound) {
            context?.unbindService(serviceConnection)
            serviceBound = false
        }

        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        backgroundService = null
        Log.d(TAG, "后台定位插件已分离")
    }
}
