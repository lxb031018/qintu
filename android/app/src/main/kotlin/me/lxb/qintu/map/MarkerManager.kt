package me.lxb.qintu.map

import android.util.Log
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.Marker
import com.amap.api.maps.model.MarkerOptions
import com.amap.api.maps.model.BitmapDescriptorFactory

/**
 * 标记管理器（功能模块层）
 *
 * 职责：
 * - 管理起点/终点标记
 * - 管理单标记（用于一般场景）
 */
class MarkerManager(private val aMapHolder: AMapHolder) {
    companion object {
        private const val TAG = "MarkerManager"
    }

    private var startMarker: Marker? = null
    private var endMarker: Marker? = null
    private val stationMarkers = mutableListOf<Marker>()

    fun setRouteMarkers(
        startLat: Double,
        startLng: Double,
        endLat: Double,
        endLng: Double,
        startLabel: String = "起点",
        endLabel: String = "终点"
    ): Boolean {
        clearRouteMarkersInternal()

        val aMap = aMapHolder.aMap ?: return false

        try {
            startMarker = aMap.addMarker(MarkerOptions()
                .position(LatLng(startLat, startLng))
                .title(startLabel)
                .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN)))

            endMarker = aMap.addMarker(MarkerOptions()
                .position(LatLng(endLat, endLng))
                .title(endLabel)
                .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED)))

            Log.d(TAG, "✅ setRouteMarkers: start=($startLat,$startLng), end=($endLat,$endLng)")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "❌ setRouteMarkers 失败: ${e.message}")
            return false
        }
    }

    fun clearRouteMarkers() {
        clearRouteMarkersInternal()
    }

    private fun clearRouteMarkersInternal() {
        try {
            startMarker?.remove()
            startMarker = null
            endMarker?.remove()
            endMarker = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ clearRouteMarkersInternal 失败: ${e.message}")
        }
    }

    fun showSingleMarker(lat: Double, lng: Double, isStart: Boolean, label: String): Boolean {
        val aMap = aMapHolder.aMap ?: return false

        try {
            val marker = aMap.addMarker(MarkerOptions()
                .position(LatLng(lat, lng))
                .title(label)
                .icon(BitmapDescriptorFactory.defaultMarker(
                    if (isStart) BitmapDescriptorFactory.HUE_GREEN else BitmapDescriptorFactory.HUE_RED)))

            if (isStart) {
                startMarker?.remove()
                startMarker = marker
            } else {
                endMarker?.remove()
                endMarker = marker
            }

            Log.d(TAG, "✅ showSingleMarker: lat=$lat, lng=$lng, isStart=$isStart")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "❌ showSingleMarker 失败: ${e.message}")
            return false
        }
    }

    fun clearSingleMarker(isStart: Boolean) {
        if (isStart) {
            startMarker?.remove()
            startMarker = null
        } else {
            endMarker?.remove()
            endMarker = null
        }
    }

    fun clearAll() {
        clearRouteMarkersInternal()
    }

    /**
     * 添加公共交通站点标记
     *
     * [stationsData] 站点数据列表，每项包含:
     *   - lat: Double - 纬度
     *   - lng: Double - 经度
     *   - name: String? - 站点名称（可选）
     *   - type: String - 站点类型 ("bus", "subway", "walk", "taxi")
     */
    fun addStationMarkers(stationsData: List<*>?): Boolean {
        if (stationsData.isNullOrEmpty()) return false

        val aMap = aMapHolder.aMap ?: return false

        try {
            clearStationMarkersInternal()

            for (station in stationsData) {
                val map = station as? Map<*, *> ?: continue
                val lat = (map["lat"] as? Number)?.toDouble() ?: continue
                val lng = (map["lng"] as? Number)?.toDouble() ?: continue
                val name = map["name"] as? String ?: ""
                val type = map["type"] as? String ?: "bus"

                val marker = aMap.addMarker(MarkerOptions()
                    .position(LatLng(lat, lng))
                    .title(name)
                    .snippet(type)
                    .icon(getStationMarkerIcon(type)))

                if (marker != null) {
                    stationMarkers.add(marker)
                }
            }

            Log.d(TAG, "✅ addStationMarkers: 添加了 ${stationMarkers.size} 个站点标记")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "❌ addStationMarkers 失败: ${e.message}")
            return false
        }
    }

    /**
     * 清除所有站点标记
     */
    fun clearStationMarkers() {
        clearStationMarkersInternal()
    }

    private fun clearStationMarkersInternal() {
        try {
            stationMarkers.forEach { it.remove() }
            stationMarkers.clear()
        } catch (e: Exception) {
            Log.e(TAG, "❌ clearStationMarkersInternal 失败: ${e.message}")
        }
    }

    /**
     * 根据站点类型获取标记图标
     */
    private fun getStationMarkerIcon(type: String): com.amap.api.maps.model.BitmapDescriptor {
        return when (type) {
            "subway" -> BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED)
            "bus" -> BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_BLUE)
            "walk" -> BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_ORANGE)
            "taxi" -> BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_YELLOW)
            else -> BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_AZURE)
        }
    }
}