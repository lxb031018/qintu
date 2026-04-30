package me.lxb.qintu

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 注册高德导航插件
        flutterEngine.plugins.add(me.lxb.qintu.AmapNavigationPlugin())

        // 注册高德地图显示插件
        flutterEngine.plugins.add(me.lxb.qintu.AmapMapPlugin())

        // 注册定位设置跳转插件
        flutterEngine.plugins.add(me.lxb.qintu.location.LocationSettingsPlugin())

        // 注册公交搜索插件
        flutterEngine.plugins.add(me.lxb.qintu.bus.AmapBusSearchPlugin())
    }
}