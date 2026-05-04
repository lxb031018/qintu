package me.lxb.qintu.map

import android.content.Context
import android.util.Log
import com.amap.api.maps.model.BitmapDescriptorFactory
import com.amap.api.maps.model.MyLocationStyle
import com.amap.api.navi.AMapNaviView
import com.amap.api.navi.AMapNaviViewListener
import com.amap.api.navi.AMapNaviViewOptions
import com.amap.api.navi.AmapPageType
import com.amap.api.navi.model.RouteOverlayOptions
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
     * 导航退出回调（由外部注入，用于通知 Flutter）
     */
    var onNaviViewExitListener: (() -> Unit)? = null

    /**
     * 创建原生 AMapNaviView
     *
     * 预览模式：路线预览时使用（autoDrawRoute=false，layoutVisible=false）
     * 导航模式：调用 enableNaviMode() 切换到全功能导航 UI
     */
    fun createNativeView(): AMapNaviView {
        val routeOverlayOptions = RouteOverlayOptions().apply {
            setRouteWidth(25)
            setArrowOnRoute(true)
            setOnRouteCameShow(true)
            setStartPointBitmap(BitmapDescriptorFactory.fromAsset("amap_start.png"))
            setEndPointBitmap(BitmapDescriptorFactory.fromAsset("amap_end.png"))
            setArrowOnTrafficRoute(BitmapDescriptorFactory.fromAsset("navi_direction.png"))
            setTrafficLine(true)
            setSmoothMove(true)
        }

        val options = AMapNaviViewOptions().apply {
            setLayoutVisible(false)
            setAutoDrawRoute(true)
            setAfterRouteAutoGray(true)
            setTrafficLine(true)
            setEagleMapVisible(true)
            setAutoLockCar(true)
            setAutoDisplayOverview(false)
            setShowCameraDistance(true)
            setNaviArrowVisible(true)
            setLaneInfoShow(true)
            setRouteListButtonShow(true)
            setTrafficBarEnabled(true)
            setBroadcastModeEnabled(true)
            setShowSettingsPanel(true)
            setShowRouteStrategyPreferencePanel(true)
            setShowNaviPopTips(true)
            setDrawBackUpOverlay(true)
            setLeaderLineEnabled(0)
            setSecondActionVisible(true)
            setRouteOverlayOptions(routeOverlayOptions)
        }
        val naviView = AMapNaviView(context, options)
        naviView.setAMapNaviViewListener(object : AMapNaviViewListener {
            override fun onNaviViewLoaded() {
                Log.d(TAG, "✅ AMapNaviView 加载完成")
            }

            override fun onNaviSetting() {}
            override fun onNaviCancel() {}
            override fun onNaviBackClick(): Boolean = false
            override fun onNaviMapMode(p0: Int) {}
            override fun onNaviTurnClick() {}
            override fun onNextRoadClick() {}
            override fun onScanViewButtonClick() {}
            override fun onLockMap(p0: Boolean) {}
            override fun onNaviViewShowMode(p0: Int) {}
            override fun onStopSpeaking() {}
            override fun onViewTypeChanged(p0: AmapPageType?) {}
            override fun onAMapNaviViewExit() {
                Log.d(TAG, "🚪 onAMapNaviViewExit 被调用")
                onNaviViewExitListener?.invoke()
            }
            override fun onListenToVoiceDuringCallChanged(p0: Boolean) {}
            override fun onControlMusicVolumeModeChanged(p0: Int) {}
            override fun onEagleChanged(p0: Boolean) {}
            override fun onNaviRouteHighlightChange(p0: Long, p1: Int) {}
            override fun onBroadcastModeChanged(p0: Int) {}
            override fun onDayAndNightModeChanged(p0: Int) {}
            override fun onScaleAutoChanged(p0: Boolean) {}
            override fun onStrategyChanged(p0: Int) {}
            override fun onMapTypeChanged(p0: Int) {}
        })
        return naviView
    }

    /**
     * 切换到导航模式：启用完整 SDK 导航 UI
     * 在 startNavi 前调用
     */
    fun enableNaviMode(naviView: AMapNaviView) {
        val options = naviView.viewOptions
        options.setLayoutVisible(true)
        options.setAutoDrawRoute(true)
        options.setAutoDisplayOverview(true)
        naviView.setViewOptions(options)
        Log.d(TAG, "🎮 导航模式已启用：SDK 完整 UI + 自动画路")
    }

    /**
     * 切换回预览模式：隐藏导航 UI，仅保留地图
     */
    fun disableNaviMode(naviView: AMapNaviView) {
        val options = naviView.viewOptions
        options.setLayoutVisible(false)
        options.setAutoDisplayOverview(false)
        naviView.setViewOptions(options)
        Log.d(TAG, "🗺️ 预览模式已启用：隐藏导航 UI，autoDrawRoute 保持开启")
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

        // 🟢 关键步骤 2：定位蓝点将在首次 setPointToCenter 后由 AmapMapPlugin 开启
        // 延迟启用是为了确保地图中心已被修正（AMapNaviView 内部预留空间会导致偏移）

        Log.d(TAG, "🔍 地图配置完成（UiSettings/定位源/图层/缩放范围，蓝点待启用）")
    }
}
