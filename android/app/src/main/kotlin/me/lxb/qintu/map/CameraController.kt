package me.lxb.qintu.map

import android.util.Log
import com.amap.api.maps.AMap
import com.amap.api.maps.model.LatLng

/**
 * 相机控制器
 */
class CameraController(private val aMap: AMap) {

    companion object {
        private const val TAG = "CameraController"
    }

    /**
     * 移动相机到指定位置
     */
    fun moveCamera(lat: Double, lng: Double, zoom: Float = 17f) {
        val latLng = LatLng(lat, lng)
        Log.d(TAG, "🎥 移动相机到: lat=$lat, lng=$lng, zoom=$zoom")
        aMap.moveCamera(
            com.amap.api.maps.CameraUpdateFactory.newLatLngZoom(latLng, zoom)
        )
    }

    /**
     * 平滑动画移动相机到指定位置
     */
    fun animateCamera(lat: Double, lng: Double, zoom: Float = 17f) {
        val latLng = LatLng(lat, lng)
        Log.d(TAG, "🎥 动画移动相机到: lat=$lat, lng=$lng, zoom=$zoom")
        aMap.animateCamera(
            com.amap.api.maps.CameraUpdateFactory.newLatLngZoom(latLng, zoom)
        )
    }
}
