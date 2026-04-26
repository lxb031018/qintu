package me.lxb.qintu.route

/**
 * 路线渲染功能抽象接口
 */
interface RouteSource {

    /**
     * 显示多条路线
     * @param routes 路线列表，每条路线是 [lat, lng] 坐标点列表
     * @param selectIndex 默认选中的路线索引
     * @return 成功显示的路线数量
     */
    fun showRoutes(routes: List<List<Map<String, Double>>>, selectIndex: Int): Int

    /**
     * 选中高亮某条路线
     * @param index 路线索引
     * @return 是否成功
     */
    fun selectRoute(index: Int): Boolean

    /**
     * 清除所有路线
     */
    fun clearRoutes()

    /**
     * 设置路线起点/终点标记
     * @return 是否成功
     */
    fun setMarkers(
        startLat: Double?,
        startLng: Double?,
        endLat: Double?,
        endLng: Double?,
        startLabel: String,
        endLabel: String
    ): Boolean

    /**
     * 清除路线标记
     */
    fun clearMarkers()
}
