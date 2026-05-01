package me.lxb.qintu.map

import android.content.Context
import android.util.Log
import com.amap.api.maps.MapView
import com.amap.api.maps.model.MyLocationStyle
import me.lxb.qintu.location.LocationClientImpl

/**
 * 地图视图工厂
 *
 * 负责创建原生 MapView 并配置地图基础属性
 */
class MapViewFactory(
    private val context: Context,
    private val locationClient: LocationClientImpl,
    private val aMapHolder: AMapHolder
) {

    companion object {
        private const val TAG = "MapViewFactory"
    }

    private var locationListener: com.amap.api.maps.LocationSource.OnLocationChangedListener? = null

    /**
     * 创建原生 MapView
     */
    fun createNativeView(): MapView {
        return MapView(context)
    }

    /**
     * 配置地图
     */
    fun configureMap(mapView: MapView) {
        val aMap = mapView.map

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
