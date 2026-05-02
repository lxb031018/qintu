package me.lxb.qintu.navigation

import com.amap.api.navi.model.AMapNaviLocation

/**
 * 导航状态持有者（单例）
 *
 * 在 NavigationImpl 回调中更新，供 RouteRenderer 读取。
 * 避免将 SDK 语义索引通过 EventChannel → Flutter → MethodChannel 往返传递。
 */
object NavigationStateHolder {
    /** 当前是否匹配（吸附）到规划路线上 */
    @Volatile
    var isMatched: Boolean = false

    /** 整条路线剩余距离（米），来自 NaviInfo.getPathRetainDistance() */
    @Volatile
    var pathRetainDistance: Int = 0

    /** 最近一次导航位置（完整对象，供 RouteOverLay.updatePolyline() 使用） */
    @Volatile
    var naviLocation: AMapNaviLocation? = null
}
