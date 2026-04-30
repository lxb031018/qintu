package me.lxb.qintu.location

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import me.lxb.qintu.constant.PlatformChannels

/**
 * 定位设置插件（Plugin 层）
 *
 * 负责处理定位设置的 Flutter 通信。
 * 业务逻辑：打开系统定位设置页面。
 */
class LocationSettingsPlugin : FlutterPlugin {

    companion object {
        private const val TAG = "LocationSettings"
    }

    private var channel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, PlatformChannels.LOCATION_SETTINGS)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "openLocationSettings" -> {
                    try {
                        val context = binding.applicationContext
                        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("SETTINGS_ERROR", "无法打开系统定位设置页面: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}