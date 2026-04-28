package me.lxb.qintu

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.amap.api.navi.AMapNavi
import com.amap.api.navi.AMapNaviListener
import com.amap.api.navi.AMapNaviView
import com.amap.api.navi.AMapNaviViewListener
import com.amap.api.navi.AMapNaviViewOptions
import com.amap.api.navi.enums.NaviType
import com.amap.api.navi.enums.PathPlanningStrategy
import com.amap.api.navi.model.AMapLaneInfo
import com.amap.api.navi.model.AMapModelCross
import com.amap.api.navi.model.AMapNaviCameraInfo
import com.amap.api.navi.model.AMapNaviCross
import com.amap.api.navi.model.AMapNaviLocation
import com.amap.api.navi.model.AMapNaviRouteNotifyData
import com.amap.api.navi.model.AMapNaviTrafficFacilityInfo
import com.amap.api.navi.model.AMapServiceAreaInfo
import com.amap.api.navi.model.AimLessModeCongestionInfo
import com.amap.api.navi.model.AimLessModeStat
import com.amap.api.navi.model.AMapCalcRouteResult
import com.amap.api.navi.model.NaviInfo
import com.amap.api.navi.model.NaviLatLng
import com.amap.api.maps.model.LatLng
import com.amap.api.navi.view.RouteOverLay
import com.amap.api.maps.model.PolylineOptions
import me.lxb.qintu.overlay.CarOverlay
import org.json.JSONArray

/**
 * 实时 GPS 导航页面
 *
 * 参考官方示例：examples/amap/navigation/android-navi-fragment-master/RouteNaviActivity.java
 *
 * 业务流程：
 * 1. onCreate: 获取 AMapNavi 单例，设置监听器
 * 2. 从 Intent 接收 routePoints (JSON 格式 [[lat, lng], ...])
 * 3. 调用 calculateDriveRoute 用已有路线点作为起终点
 * 4. onCalculateRouteSuccess: 调用 startNavi(NaviType.GPS) 开始实时导航
 * 5. AMapNaviView 生命周期透传
 */
class NavigationActivity : AppCompatActivity(), AMapNaviListener, AMapNaviViewListener {

    companion object {
        private const val TAG = "NavigationActivity"
        const val EXTRA_ROUTE_POINTS = "routePoints"
        const val EXTRA_ENABLE_VOICE = "enableVoice"
        const val ACTION_LOCATION_UPDATE = "me.lxb.qintu.LOCATION_UPDATE"
        const val ACTION_NAVI_INFO_UPDATE = "me.lxb.qintu.NAVI_INFO_UPDATE"
        const val ACTION_STOP_NAVIGATION = "STOP_NAVIGATION"
    }

    private lateinit var mAMapNavi: AMapNavi
    private var mAMapNaviView: AMapNaviView? = null
    private var mEnableVoice: Boolean = true
    private var carOverlay: CarOverlay? = null
    private var routeOverLay: RouteOverLay? = null

    // 导航路线点（从 Flutter 传入）
    private val mRoutePoints = mutableListOf<NaviLatLng>()

    // 停止导航广播接收器
    private val stopNavReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == ACTION_STOP_NAVIGATION) {
                finish()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_navigation)

        // 1. 获取 AMapNavi 单例
        mAMapNavi = AMapNavi.getInstance(applicationContext)
        mAMapNavi.addAMapNaviListener(this)
        // 驾车和骑步行视图切换时，需要重置视图类型，避免底层不同视图处理异常
        mAMapNavi.setIsNaviTravelView(false)

        // 2. 从 Intent 获取参数
        mEnableVoice = intent.getBooleanExtra(EXTRA_ENABLE_VOICE, true)
        mAMapNavi.setUseInnerVoice(mEnableVoice)

        val routePointsJson = intent.getStringExtra(EXTRA_ROUTE_POINTS)
        if (routePointsJson.isNullOrEmpty()) {
            Log.e(TAG, "routePoints 为空，无法开始导航")
            finish()
            return
        }

        parseRoutePoints(routePointsJson)

        if (mRoutePoints.size < 2) {
            Log.e(TAG, "路线点不足，至少需要 2 个点")
            finish()
            return
        }

        Log.d(TAG, "✅ 解析到 ${mRoutePoints.size} 个路线点")
        Log.d(TAG, "   起点: ${mRoutePoints.first().latitude}, ${mRoutePoints.first().longitude}")
        Log.d(TAG, "   终点: ${mRoutePoints.last().latitude}, ${mRoutePoints.last().longitude}")

        // 3. 设置 AMapNaviView
        mAMapNaviView = findViewById(R.id.navi_view)
        mAMapNaviView!!.onCreate(savedInstanceState)
        mAMapNaviView!!.setAMapNaviViewListener(this)

        // 配置导航视图选项
        val options = AMapNaviViewOptions().apply {
            isAutoDrawRoute = false          // 关闭自动绘制路线，由 RouteOverLay 手动绘制
            isSettingMenuEnabled = false     // 不显示设置菜单
            isTrafficLine = false             // 不显示交通路况线条
        }
        mAMapNaviView!!.viewOptions = options

        Log.d(TAG, "✅ AMapNaviView 初始化完成，autoDrawRoute=${options.isAutoDrawRoute}")

        // GPS 定位配置
        mAMapNavi.setIsUseExtraGPSData(false)  // 不使用外部GPS数据，使用自带GPS
        Log.d(TAG, "GPS 配置完成")

        // 注册停止导航广播接收器
        LocalBroadcastManager.getInstance(this).registerReceiver(
            stopNavReceiver,
            IntentFilter(ACTION_STOP_NAVIGATION)
        )

        // 初始化自定义车辆Overlay
        carOverlay = CarOverlay(this)
        Log.d(TAG, "✅ CarOverlay 初始化完成")

        // 4. 直接用 PolylineOptions 绘制路线（不依赖 SDK 路线计算）
        val map = mAMapNaviView?.map
        if (map != null && mRoutePoints.size >= 2) {
            try {
                // 将 NaviLatLng 转换为 LatLng
                val latLngPoints = mRoutePoints.map { LatLng(it.latitude, it.longitude) }
                val polyline = map.addPolyline(
                    PolylineOptions()
                        .addAll(latLngPoints)
                        .color(0xFF1890FF.toInt())
                        .width(12f)
                )
                Log.d(TAG, "✅ 路线绘制完成: ${mRoutePoints.size} 个点")

                // 移动相机到路线起点
                val firstPoint = mRoutePoints.first()
                map.moveCamera(
                    com.amap.api.maps.CameraUpdateFactory.newLatLng(
                        com.amap.api.maps.model.LatLng(firstPoint.latitude, firstPoint.longitude)
                    )
                )
            } catch (e: Exception) {
                Log.e(TAG, "❌ 路线绘制失败: ${e.message}")
            }
        } else {
            Log.w(TAG, "⚠️ 地图或路线点为空，跳过路线绘制")
        }

        // 5. 直接启动导航（无需 SDK 路线计算）
        val ret = mAMapNavi.startNavi(NaviType.GPS)
        Log.d(TAG, "   startNavi(GPS) 返回: $ret")
    }

    /**
     * 解析路线点 JSON
     * 格式: [[lat, lng], [lat, lng], ...]
     */
    private fun parseRoutePoints(json: String) {
        try {
            val jsonArray = JSONArray(json)
            for (i in 0 until jsonArray.length()) {
                val point = jsonArray.getJSONArray(i)
                val lat = point.getDouble(0)
                val lng = point.getDouble(1)
                mRoutePoints.add(NaviLatLng(lat, lng))
            }
            Log.d(TAG, "✅ 解析到 ${mRoutePoints.size} 个路线点")
            Log.d(TAG, "   起点: ${mRoutePoints.first().latitude}, ${mRoutePoints.first().longitude}")
            Log.d(TAG, "   终点: ${mRoutePoints.last().latitude}, ${mRoutePoints.last().longitude}")
        } catch (e: Exception) {
            Log.e(TAG, "❌ 解析路线点失败: $e")
        }
    }

    // ==================== AMapNaviListener ====================

    override fun onInitNaviSuccess() {
        Log.d(TAG, "✅ onInitNaviSuccess 导航初始化成功")
    }

    override fun onInitNaviFailure() {
        Log.e(TAG, "❌ onInitNaviFailure 导航初始化失败")
    }

    @Suppress("CONFLICTING_OVERRIDES")
    override fun onCalculateRouteSuccess(result: AMapCalcRouteResult?) {
        // 由于不再调用 calculateDriveRoute，此回调不会被触发
        Log.d(TAG, "onCalculateRouteSuccess 被调用但已不再需要")
    }

    @Suppress("CONFLICTING_OVERRIDES")
    override fun onCalculateRouteFailure(result: AMapCalcRouteResult?) {
        // 由于不再调用 calculateDriveRoute，此回调不会被触发
        Log.d(TAG, "onCalculateRouteFailure 被调用但已不再需要")
    }

    // 以下两个方法是抽象接口方法的旧版签名，保留空实现以满足接口契约
    override fun onCalculateRouteSuccess(ints: IntArray?) {}
    override fun onCalculateRouteFailure(errorCode: Int) {}

    override fun onStartNavi(type: Int) {
        Log.d(TAG, "✅ onStartNavi 导航已启动 type=$type")
    }

    override fun onLocationChange(location: AMapNaviLocation?) {
        // 实时位置更新，发送给 Flutter
        location?.let {
            val coord = it.coord
            Log.d(TAG, "📍 位置更新: ${coord.latitude}, ${coord.longitude}, " +
                    "速度=${it.speed}km/h, 方向=${it.bearing}°, " +
                    "精度=${it.accuracy}m, 定位方式=${it.locationType}")

            // 更新自定义车辆标记
            val map = mAMapNaviView?.map
            if (map != null && carOverlay != null) {
                val latLng = LatLng(coord.latitude, coord.longitude)
                carOverlay?.draw(map, latLng, it.bearing)
            }

            // 发送位置广播
            val intent = Intent(ACTION_LOCATION_UPDATE).apply {
                putExtra("lat", coord.latitude)
                putExtra("lng", coord.longitude)
                putExtra("speed", it.speed.toDouble())
                putExtra("bearing", it.bearing.toDouble())
                putExtra("accuracy", it.accuracy.toDouble())
            }
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
        } ?: Log.d(TAG, "📍 位置更新: location 为 null")
    }

    override fun onNaviInfoUpdate(naviInfo: NaviInfo?) {
        // 导航信息更新（剩余距离、时间、下一指令等），发送给 Flutter
        naviInfo?.let {
            Log.d(TAG, "🧭 导航信息: 剩余距离=${it.pathRetainDistance}米, 剩余时间=${it.pathRetainTime}秒, 下一指令=${it.nextRoadName}")
            // 发送导航信息广播
            val intent = Intent(ACTION_NAVI_INFO_UPDATE).apply {
                putExtra("pathRetainDistance", it.pathRetainDistance)
                putExtra("pathRetainTime", it.pathRetainTime)
                putExtra("nextRoadName", it.nextRoadName ?: "")
                putExtra("currentRoadName", it.currentRoadName ?: "")
            }
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
        }
    }

    override fun onArriveDestination() {
        Log.d(TAG, "已到达目的地")
    }

    
    override fun onNaviRouteNotify(routeNotifyData: AMapNaviRouteNotifyData?) {
        // 导航路线通知（如路线变化）
    }

    override fun onGpsSignalWeak(isWeak: Boolean) {
        Log.d(TAG, "GPS 信号弱: $isWeak")
    }

    override fun onMapTypeChanged(mapType: Int) {
        // 地图类型变化
    }

    override fun onReCalculateRouteForYaw() {
        Log.d(TAG, "偏航，重新计算路线")
    }

    override fun onReCalculateRouteForTrafficJam() {
        Log.d(TAG, "拥堵，重新计算路线")
    }

    override fun onArrivedWayPoint(wayPointID: Int) {
        Log.d(TAG, "到达途经点: $wayPointID")
    }

    override fun onGetNavigationText(type: Int, text: String?) {
        Log.d(TAG, "导航播报[$type]: $text")
    }

    override fun onGetNavigationText(s: String?) {
        Log.d(TAG, "导航播报: $s")
    }

    override fun onEndEmulatorNavi() {
        Log.d(TAG, "模拟导航结束")
    }

    override fun onGpsOpenStatus(enabled: Boolean) {
        Log.d(TAG, "GPS 状态: ${if (enabled) "开启" else "关闭"}")
    }

    override fun updateCameraInfo(cameras: Array<out AMapNaviCameraInfo>?) {
        // 摄像头信息更新
    }

    override fun updateIntervalCameraInfo(
        cameraInfo: AMapNaviCameraInfo?,
        cameraInfo1: AMapNaviCameraInfo?,
        interval: Int
    ) {
        // 分段摄像头信息
    }

    override fun onServiceAreaUpdate(serviceAreaInfos: Array<out AMapServiceAreaInfo>?) {
        // 服务区信息
    }

    override fun showCross(cross: AMapNaviCross?) {
        // 显示路口放大图
    }

    override fun hideCross() {
        // 隐藏路口放大图
    }

    override fun showModeCross(cross: AMapModelCross?) {
        // 显示分屏路口图
    }

    override fun hideModeCross() {
        // 隐藏分屏路口图
    }

    override fun showLaneInfo(
        laneInfos: Array<out AMapLaneInfo>?,
        laneBackground: ByteArray?,
        laneRecommended: ByteArray?
    ) {
        // 显示车道信息
    }

    override fun showLaneInfo(laneInfo: AMapLaneInfo?) {
        // 显示车道信息
    }

    override fun hideLaneInfo() {
        // 隐藏车道信息
    }

    override fun notifyParallelRoad(parallelRoadType: Int) {
        // 并行道路状态
    }

    override fun updateAimlessModeStatistics(cruiseInfo: AimLessModeStat?) {
        // 巡航模式统计
    }

    override fun updateAimlessModeCongestionInfo(congestionInfo: AimLessModeCongestionInfo?) {
        // 巡航模式拥堵信息
    }

    override fun onPlayRing(ringType: Int) {
        // 播放提示音
    }

    override fun onTrafficStatusUpdate() {
        // 交通状态更新
    }

    override fun OnUpdateTrafficFacility(trafficFacilityInfo: AMapNaviTrafficFacilityInfo?) {
        // 交通设施信息
    }

    override fun OnUpdateTrafficFacility(trafficFacilityInfos: Array<out AMapNaviTrafficFacilityInfo>?) {
        // 交通设施信息
    }

    // ==================== AMapNaviViewListener ====================

    override fun onNaviSetting() {
        // 用户点击导航设置按钮
    }

    override fun onNaviCancel() {
        // 用户点击取消导航
        finish()
    }

    override fun onNaviBackClick(): Boolean {
        // 返回按钮点击
        return false
    }

    override fun onNaviMapMode(mode: Int) {
        // 地图模式变化（2D/3D）
    }

    override fun onNaviTurnClick() {
        // 点击转向图标
    }

    override fun onNextRoadClick() {
        // 点击下一道路按钮
    }

    override fun onScanViewButtonClick() {
        // 点击全景按钮
    }

    override fun onLockMap(isLock: Boolean) {
        // 地图锁定状态变化
    }

override fun onNaviViewLoaded() {
        Log.d(TAG, "导航视图加载完成")
    }

    override fun onNaviViewShowMode(showMode: Int) {
        // 导航视图显示模式变化
    }

    override fun onStopSpeaking() {
        // 停止语音播报
    }

    override fun onViewTypeChanged(viewType: com.amap.api.navi.AmapPageType?) {
        // 视图类型变化
    }

    override fun onAMapNaviViewExit() {
        // 导航视图退出
    }

    override fun onStrategyChanged(strategy: Int) {
        // 策略变化
    }

    override fun onBroadcastModeChanged(mode: Int) {
        // 导航播报模式变化
    }

    override fun onDayAndNightModeChanged(mode: Int) {
        // 日夜模式变化
    }

    override fun onScaleAutoChanged(isAuto: Boolean) {
        // 比例尺自动变化
    }

    override fun onListenToVoiceDuringCallChanged(listen: Boolean) {
        // 通话时监听语音变化
    }

    override fun onControlMusicVolumeModeChanged(mode: Int) {
        // 音乐音量模式变化
    }

    override fun onEagleChanged(isEagle: Boolean) {
        // 鹰眼视图变化
    }

    override fun onNaviRouteHighlightChange(routeId: Long, routeType: Int) {
        // 导航路线高亮变化
    }

    override fun onResume() {
        super.onResume()
        mAMapNaviView?.onResume()
    }

    override fun onPause() {
        super.onPause()
        mAMapNaviView?.onPause()
        // 暂停导航（但保持引擎运行）
        mAMapNavi.pauseNavi()
    }

    override fun onDestroy() {
        super.onDestroy()
        // 注销广播接收器
        LocalBroadcastManager.getInstance(this).unregisterReceiver(stopNavReceiver)

        // 释放CarOverlay资源
        carOverlay?.destroy()
        carOverlay = null

        // 释放RouteOverLay资源
        routeOverLay?.removeFromMap()
        routeOverLay?.destroy()
        routeOverLay = null

        mAMapNaviView?.onDestroy()
        // 停止导航并释放资源
        mAMapNavi.stopNavi()
        mAMapNavi.removeAMapNaviListener(this)
    }
}
