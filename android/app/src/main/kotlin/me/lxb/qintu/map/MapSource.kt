package me.lxb.qintu.map

import android.content.Context
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * 地图功能抽象接口
 */
interface MapSource {

    /**
     * 创建地图 PlatformView
     */
    fun createPlatformView(context: Context, viewId: Int): PlatformView

    /**
     * 移动相机到指定位置
     */
    fun moveCamera(lat: Double, lng: Double, zoom: Float)

    /**
     * 激活定位源
     */
    fun activateLocationSource(listener: com.amap.api.maps.LocationSource.OnLocationChangedListener)

    /**
     * 取消激活定位源
     */
    fun deactivateLocationSource()

    /**
     * 设置是否显示定位层
     */
    fun setMyLocationEnabled(enabled: Boolean)
}
