package me.lxb.qintu.map

import com.amap.api.maps.AMap

/**
 * AMap 持有者，用于在 MapViewFactory 创建地图后共享 AMap 实例
 */
class AMapHolder {

    private var _aMap: AMap? = null

    val aMap: AMap?
        get() = _aMap

    fun setMap(map: AMap) {
        _aMap = map
    }
}
