package me.lxb.qintu.route

import com.amap.api.navi.model.AMapNaviPath

/**
 * AMapNaviPath 共享缓存
 *
 * 桥接 AmapNavigationPlugin（算路）与 AmapMapPlugin（渲染），
 * 使 RouteRenderer 可以通过 routeId 获取 AMapNaviPath 并使用 RouteOverLay 渲染带方向箭头的路线。
 */
object RoutePathCache {

    private val cache = mutableMapOf<Int, AMapNaviPath>()

    fun put(routeId: Int, path: AMapNaviPath) {
        cache[routeId] = path
    }

    fun putAll(paths: Map<Int, AMapNaviPath>) {
        cache.putAll(paths)
    }

    fun get(routeId: Int): AMapNaviPath? = cache[routeId]

    fun getAll(): Map<Int, AMapNaviPath> = cache.toMap()

    fun clear() {
        cache.clear()
    }

    fun size(): Int = cache.size
}
