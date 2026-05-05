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
}