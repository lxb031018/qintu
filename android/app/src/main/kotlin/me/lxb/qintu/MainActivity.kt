package me.lxb.qintu

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val LOCATION_SETTINGS_CHANNEL = "qintu/location_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 注册高德导航插件
        flutterEngine.plugins.add(AmapNavigationPlugin())

        // 注册高德地图显示插件
        flutterEngine.plugins.add(AmapMapPlugin())

        // 注册定位设置跳转 Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_SETTINGS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openLocationSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("SETTINGS_ERROR", "无法打开系统定位设置页面: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
