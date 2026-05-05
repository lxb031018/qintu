package me.lxb.qintu

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.view.WindowManager
import android.util.Log

class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "MainActivity"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 清除任何遗留的屏幕常亮设置（确保应用启动时屏幕跟随系统设置）
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        Log.d(TAG, "📍 应用启动，已清除屏幕常亮 flag, flags=${window.attributes.flags}")

        // 注册高德导航插件
        flutterEngine.plugins.add(me.lxb.qintu.AmapNavigationPlugin())

        // 注册高德地图显示插件
        flutterEngine.plugins.add(me.lxb.qintu.AmapMapPlugin())

        // 注册定位设置跳转插件
        flutterEngine.plugins.add(me.lxb.qintu.location.LocationSettingsPlugin())

        // 注册公交搜索插件
        flutterEngine.plugins.add(me.lxb.qintu.bus.AmapBusSearchPlugin())

        // 注册地理编码插件
        flutterEngine.plugins.add(me.lxb.qintu.geocode.GeocodePlugin())

        // 注册 POI 搜索插件
        flutterEngine.plugins.add(me.lxb.qintu.poi.PoiSearchPlugin())

        // 注册后台定位插件
        flutterEngine.plugins.add(me.lxb.qintu.background.BackgroundLocationPlugin())
    }
}