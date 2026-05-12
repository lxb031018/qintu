package me.lxb.qintu.map

import android.content.Context
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.view.ViewTreeObserver
import com.amap.api.maps.model.MyLocationStyle
import com.amap.api.navi.AMapNaviView
import com.amap.api.navi.AMapNaviViewListener
import com.amap.api.navi.AMapNaviViewOptions
import com.amap.api.navi.AmapPageType
import io.flutter.plugin.platform.PlatformView
import me.lxb.qintu.location.LocationClientImpl
import me.lxb.qintu.overlay.CarOverlay

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

    data class MapComponents(
        val cameraController: CameraController,
        val routeRenderer: RouteRenderer,
        val markerManager: MarkerManager,
        val gestureHandler: GestureHandler
    )

    data class PlatformViewCreatedResult(
        val platformView: PlatformView,
        val naviView: AMapNaviView,
        val mapComponents: MapComponents
    )

    private var locationListener: com.amap.api.maps.LocationSource.OnLocationChangedListener? = null

    /**
     * 导航退出回调（由外部注入，用于通知 Flutter）
     */
    var onNaviViewExitListener: (() -> Unit)? = null

    /**
     * 导航视图加载完成回调（由外部注入，用于通知 RouteRenderer）
     */
    var onNaviViewLoadedCallback: (() -> Unit)? = null

    /**
     * 首次定位就绪回调（由外部注入，携带定位数据）
     */
    var onFirstLocationReady: ((Double, Double, Double, String) -> Unit)? = null

    private var firstLocationPending: com.amap.api.location.AMapLocation? = null
    private var myLocationEnabled = false

    /**
     * 创建原生 AMapNaviView
     *
     * 预览模式：路线预览时使用（autoDrawRoute=false，layoutVisible=false）
     * 导航模式：调用 enableNaviMode() 切换到全功能导航 UI
     */
    fun createNativeView(): AMapNaviView {
        val options = AMapNaviViewOptions().apply {
            setLayoutVisible(false)
            setAutoDrawRoute(false)
            setAfterRouteAutoGray(true)
            setTrafficLine(true)
            setEagleMapVisible(true)
            setAutoLockCar(true)
            setAutoDisplayOverview(true)
            setShowCameraDistance(true)
            setNaviArrowVisible(true)
            setLaneInfoShow(true)
            setRouteListButtonShow(true)
            setTrafficBarEnabled(true)
            setBroadcastModeEnabled(true)
            setShowSettingsPanel(true)
            setShowRouteStrategyPreferencePanel(true)
            setShowNaviPopTips(true)
            setDrawBackUpOverlay(false)  // 禁用备选路线，由 RouteOverLay 统一管理
            setLeaderLineEnabled(0)
            setSecondActionVisible(true)
        }
        val naviView = AMapNaviView(context, options)
        naviView.setAMapNaviViewListener(object : AMapNaviViewListener {
            override fun onNaviViewLoaded() {
                Log.d(TAG, "✅ AMapNaviView 加载完成")
                onNaviViewLoadedCallback?.invoke()
            }

            override fun onNaviSetting() {}

            /** 统一的退出处理逻辑 */
            private fun handleNaviExit() {
                Log.d(TAG, "🚪 导航退出，统一处理")
                onNaviViewExitListener?.invoke()
            }

            override fun onNaviCancel() {
                Log.d(TAG, "🚪 onNaviCancel 被调用")
                handleNaviExit()
            }

            override fun onNaviBackClick(): Boolean {
                Log.d(TAG, "🚪 onNaviBackClick 被调用，返回 false 让 SDK 显示确认对话框")
                return false  // false = SDK 显示"退出导航"确认对话框，防止误触
            }

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
                handleNaviExit()
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
        val aMap = naviView.map ?: run {
            Log.w(TAG, "⚠️ naviView.map is null in enableNaviMode")
            return
        }
        val options = naviView.viewOptions
        options.setLayoutVisible(true)
        options.setAutoDrawRoute(true)
        options.setAutoDisplayOverview(true)
        options.setSecondActionVisible(true)
        options.setNaviArrowVisible(true)
        options.setRouteListButtonShow(true)
        naviView.setViewOptions(options)

        // 导航模式：隐藏定位蓝点，由 CarOverlay 替代显示
        // 同时使用 isMyLocationEnabled 和 showMyLocation(false) 确保蓝点完全消失
        aMap.isMyLocationEnabled = false
        val myLocationStyle = MyLocationStyle()
        myLocationStyle.showMyLocation(false)
        myLocationStyle.radiusFillColor(0x301890FF.toInt())
        myLocationStyle.strokeColor(0xFF1890FF.toInt())
        myLocationStyle.strokeWidth(2f)
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE)
        myLocationStyle.interval(2000)
        aMap.myLocationStyle = myLocationStyle
        Log.d(TAG, "🎮 导航模式已启用：SDK 完整 UI，定位蓝点已隐藏")
    }

    /**
     * 切换回预览模式：隐藏导航 UI，仅保留地图
     */
    fun disableNaviMode(naviView: AMapNaviView) {
        val aMap = naviView.map ?: run {
            Log.w(TAG, "⚠️ naviView.map is null in disableNaviMode")
            return
        }
        val options = naviView.viewOptions
        options.setLayoutVisible(false)
        options.setAutoDisplayOverview(false)
        naviView.setViewOptions(options)

        // 预览模式：恢复定位蓝点
        // 同时使用 isMyLocationEnabled 和 showMyLocation(true) 确保蓝点正常显示
        aMap.isMyLocationEnabled = true
        val myLocationStyle = MyLocationStyle()
        myLocationStyle.showMyLocation(true)
        myLocationStyle.radiusFillColor(0x301890FF.toInt())
        myLocationStyle.strokeColor(0xFF1890FF.toInt())
        myLocationStyle.strokeWidth(2f)
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE)
        myLocationStyle.interval(2000)
        aMap.myLocationStyle = myLocationStyle
        Log.d(TAG, "🗺️ 预览模式已启用：隐藏导航 UI，autoDrawRoute 保持开启，定位蓝点已恢复")
    }

    /**
     * 配置地图（适配 AMapNaviView）
     */
    fun configureMap(naviView: AMapNaviView) {
        val aMap = naviView.map ?: run {
            Log.w(TAG, "⚠️ naviView.map is null in configureMap")
            return
        }

        // ======== 定位蓝点样式 ========
        val myLocationStyle = MyLocationStyle()
        myLocationStyle.showMyLocation(true)
        myLocationStyle.radiusFillColor(0x301890FF.toInt()) // 半透明蓝色精度圈
        myLocationStyle.strokeColor(0xFF1890FF.toInt())       // 蓝色描边
        myLocationStyle.strokeWidth(2f)
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE)
        myLocationStyle.interval(2000) // 定位间隔 2 秒
        aMap.myLocationStyle = myLocationStyle
        aMap.isMyLocationEnabled = true  // 预览模式默认显示蓝点

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

        // 🟢 关键步骤 2：定位蓝点已在预览模式默认开启
        // 首次布局时会修正地图中心（AMapNaviView 内部预留空间会导致偏移）

        Log.d(TAG, "🔍 地图配置完成（UiSettings/定位源/图层/缩放范围，蓝点待启用）")
    }

    /**
     * 创建地图组件（CameraController, RouteRenderer, MarkerManager, GestureHandler）
     */
    fun createMapComponents(
        aMap: com.amap.api.maps.AMap,
        carOverlayRef: () -> CarOverlay?,
        currentNaviViewRef: () -> AMapNaviView?
    ): MapComponents {
        val cameraController = CameraController(aMap)
        val routeRenderer = RouteRenderer(aMapHolder, currentNaviViewRef)
        val markerManager = MarkerManager(aMapHolder)
        val gestureHandler = GestureHandler(
            cameraController,
            carOverlayRef,
            aMapHolder,
            { }
        )
        return MapComponents(cameraController, routeRenderer, markerManager, gestureHandler)
    }

    /**
     * 创建 PlatformView，包含完整的视图初始化逻辑
     */
    fun createPlatformView(
        viewId: Int,
        carOverlayRef: () -> CarOverlay?,
        currentNaviViewRef: () -> AMapNaviView?,
        onMapTouched: () -> Unit
    ): PlatformViewCreatedResult {
        val naviView = createNativeView().apply {
            onCreate(null)
            onResume()
        }

        val aMap = naviView.map
        aMapHolder.setMap(aMap)
        configureMap(naviView)

        val mapComponents = createMapComponents(aMap, carOverlayRef, currentNaviViewRef)

        naviView.viewTreeObserver.addOnGlobalLayoutListener(
            object : ViewTreeObserver.OnGlobalLayoutListener {
                override fun onGlobalLayout() {
                    if (naviView.width > 0 && naviView.height > 0) {
                        val aMap = naviView.map
                        if (aMap == null) {
                            Log.w(TAG, "⚠️ naviView.map is null in OnGlobalLayoutListener，跳过布局修正")
                            return
                        }
                        val centerX = naviView.width / 2
                        val centerY = naviView.height / 2
                        mapComponents.cameraController.setViewSize(naviView.width, naviView.height)
                        aMap.setPointToCenter(centerX, centerY)

                        if (!myLocationEnabled) {
                            myLocationEnabled = true
                            aMap.isMyLocationEnabled = true
                            Log.d(TAG, "🔵 首次布局完成，中心已修正，启用定位蓝点")
                        }

                        firstLocationPending?.let { location ->
                            onFirstLocationReady?.invoke(
                                location.latitude,
                                location.longitude,
                                location.accuracy.toDouble(),
                                location.city ?: ""
                            )
                            firstLocationPending = null
                            Log.d(TAG, "🚀 暂存的首次定位事件已发送")
                        }
                    }
                }
            }
        )

        aMap.setOnMapTouchListener { motionEvent ->
            if (motionEvent.action == MotionEvent.ACTION_UP) {
                onMapTouched()
            }
        }

        Log.d(TAG, "🗺️ AMapNaviView #$viewId 初始化完成")

        val platformView = object : PlatformView {
            override fun getView(): View = naviView

            override fun dispose() {
                naviView.onPause()
                naviView.onDestroy()
            }
        }

        return PlatformViewCreatedResult(platformView, naviView, mapComponents)
    }

    /**
     * 设置待发送的首次定位数据（视图未就绪时暂存）
     */
    fun setPendingFirstLocation(location: com.amap.api.location.AMapLocation) {
        firstLocationPending = location
    }
}
