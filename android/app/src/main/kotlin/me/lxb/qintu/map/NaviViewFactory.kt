package me.lxb.qintu.map

import android.content.Context
import android.util.Log
import com.amap.api.maps.model.MyLocationStyle
import com.amap.api.navi.AMapNaviView
import com.amap.api.navi.AMapNaviViewOptions
import me.lxb.qintu.location.LocationClientImpl

/**
 * 导航视图工厂
 *
 * 负责创建原生 AMapNaviView 并配置地图基础属性
 */
class NaviViewFactory(
    private val context: Context,
    private val locationClient: LocationClientImpl,
    private val aMapHolder: AMapHolder
) {

    companion object {
        private const val TAG = "NaviViewFactory"
    }

    private var locationListener: com.amap.api.maps.LocationSource.OnLocationChangedListener? = null

    /**
     * 创建原生 AMapNaviView
     */
    fun createNativeView(): AMapNaviView {
        val options = AMapNaviViewOptions().apply {
            // ======== 路线渲染 ========
            setAfterRouteAutoGray(true)           // 已过路段自动灰线（RouteOverLay 模式下可用）
            setAutoDrawRoute(false)              // 禁止自动画路（由 RouteRenderer 手动管理）
            setDrawBackUpOverlay(false)          // 禁止绘制备选路线（由 Flutter 层控制）
            setNaviArrowVisible(false)           // 隐藏内置导航箭头（使用 RouteOverLay 箭头）

            // ======== 导航 UI 元素 ========
            setLayoutVisible(false)              // 隐藏内置导航 UI（由 Flutter 控制）
            setEagleMapVisible(false)            // 隐藏鹰眼小地图
            setLaneInfoShow(false)               // 隐藏车道信息
            setLeaderLineEnabled(0)              // 禁用终点引导线
            setSecondActionVisible(false)        // 隐藏第二步转向提示
            setRouteListButtonShow(false)        // 隐藏全览按钮
            setTrafficBarEnabled(false)          // 隐藏路况光柱条
            setBroadcastModeEnabled(false)       // 隐藏播报模式控件

            // ======== 面板与提示 ========
            setShowSettingsPanel(false)          // 隐藏默认设置面板
            setShowRouteStrategyPreferencePanel(false)  // 隐藏路线策略偏好面板
            setShowCameraDistance(false)         // 隐藏电子眼距离
            setShowNaviPopTips(false)            // 隐藏底部提示条

            // ======== 锁车与缩放 ========
            setAutoLockCar(false)                // 禁止 SDK 自动锁车（由 MapController 自定义 Handler 控制）
            setAutoDisplayOverview(false)        // 禁止算路后自动全览
        }
        return AMapNaviView(context, options)
    }

    /**
     * 配置地图（适配 AMapNaviView）
     */
    fun configureMap(naviView: AMapNaviView) {
        val aMap = naviView.map

        // ======== 定位蓝点样式 ========
        val myLocationStyle = MyLocationStyle()
        myLocationStyle.showMyLocation(true)
        myLocationStyle.radiusFillColor(0x301890FF.toInt()) // 半透明蓝色精度圈
        myLocationStyle.strokeColor(0xFF1890FF.toInt())       // 蓝色描边
        myLocationStyle.strokeWidth(2f)
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE)
        myLocationStyle.interval(2000) // 定位间隔 2 秒
        aMap.myLocationStyle = myLocationStyle
        aMap.isMyLocationEnabled = false

        // ======== UiSettings ========
        val ui = aMap.uiSettings
        ui.isZoomControlsEnabled = false       // 隐藏原生缩放按钮，Flutter 侧自定义
        ui.isCompassEnabled = true             // 显示指南针
        ui.isScaleControlsEnabled = true       // 显示比例尺
        ui.isMyLocationButtonEnabled = false   // 隐藏原生定位按钮，Flutter 侧自定义
        ui.isScrollGesturesEnabled = true
        ui.isZoomGesturesEnabled = true
        ui.isTiltGesturesEnabled = true
        ui.isRotateGesturesEnabled = true
        ui.logoPosition = com.amap.api.maps.AMapOptions.LOGO_POSITION_BOTTOM_LEFT

        // ======== 地图显示 ========
        aMap.isTrafficEnabled = false          // 默认关闭路况，由 Flutter 控制
        aMap.showBuildings(true)
        aMap.showIndoorMap(true)
        aMap.showMapText(true)
        aMap.setMinZoomLevel(3f)
        aMap.setMaxZoomLevel(19f)

        // 🟢 关键步骤 1：先设置定位源
        aMap.setLocationSource(object : com.amap.api.maps.LocationSource {
            override fun activate(listener: com.amap.api.maps.LocationSource.OnLocationChangedListener?) {
                locationListener = listener
                locationClient.setMapLocationListener(listener)
                Log.d(TAG, "🔥 高德地图 LocationSource 已被激活")
            }

            override fun deactivate() {
                locationListener = null
                locationClient.setMapLocationListener(null)
                Log.d(TAG, "🔥 高德地图 LocationSource 已被取消激活")
            }
        })

        // 🟢 关键步骤 2：再开启定位功能
        aMap.isMyLocationEnabled = true

        Log.d(TAG, "🔍 地图配置完成（UiSettings/定位蓝点/图层/缩放范围）")
    }
}
