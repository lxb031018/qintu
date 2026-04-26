package me.lxb.qintu.location

import com.amap.api.location.AMapLocation
import io.flutter.plugin.common.MethodChannel

/**
 * 定位功能抽象接口
 */
interface LocationSource {

    /**
     * 开始持续定位
     */
    fun startLocation()

    /**
     * 停止定位
     */
    fun stopLocation()

    /**
     * 设置是否为单次定位
     */
    fun setOnceLocation(once: Boolean)

    /**
     * 获取最后已知位置
     */
    fun getLastKnownLocation(): AMapLocation?

    /**
     * 设置定位监听器
     */
    fun setLocationChangeListener(listener: (AMapLocation) -> Unit)

    /**
     * 设置首次定位成功监听器（只会触发一次）
     */
    fun setFirstLocationListener(listener: (AMapLocation) -> Unit)

    /**
     * 销毁定位客户端
     */
    fun destroy()
}
