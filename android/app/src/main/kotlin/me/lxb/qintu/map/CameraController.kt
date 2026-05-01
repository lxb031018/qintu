package me.lxb.qintu.map

import android.util.Log
import com.amap.api.maps.AMap
import com.amap.api.maps.model.CameraPosition
import com.amap.api.maps.model.LatLng

/**
 * 相机控制器
 */
class CameraController(private val aMap: AMap) {

    companion object {
        private const val TAG = "CameraController"
        private const val DEFAULT_ZOOM = 17f
    }

    /**
     * 移动相机到指定位置（瞬间跳转）
     */
    fun moveCamera(lat: Double, lng: Double, zoom: Float = DEFAULT_ZOOM,
                   bearing: Float = -1f, tilt: Float = -1f) {
        val latLng = LatLng(lat, lng)
        Log.d(TAG, "🎥 移动相机到: lat=$lat, lng=$lng, zoom=$zoom, bearing=$bearing, tilt=$tilt")
        val update = if (bearing >= 0 || tilt >= 0) {
            val builder = CameraPosition.builder()
                .target(latLng)
                .zoom(zoom)
            if (bearing >= 0) builder.bearing(bearing)
            if (tilt >= 0) builder.tilt(tilt)
            com.amap.api.maps.CameraUpdateFactory.newCameraPosition(builder.build())
        } else {
            com.amap.api.maps.CameraUpdateFactory.newLatLngZoom(latLng, zoom)
        }
        aMap.moveCamera(update)
    }

    /**
     * 平滑动画移动相机到指定位置
     */
    fun animateCamera(lat: Double, lng: Double, zoom: Float = DEFAULT_ZOOM,
                      bearing: Float = -1f, tilt: Float = -1f,
                      durationMs: Int = 0) {
        val latLng = LatLng(lat, lng)
        Log.d(TAG, "🎥 动画移动相机到: lat=$lat, lng=$lng, zoom=$zoom, bearing=$bearing, tilt=$tilt, duration=$durationMs")
        val update = if (bearing >= 0 || tilt >= 0) {
            val builder = CameraPosition.builder()
                .target(latLng)
                .zoom(zoom)
            if (bearing >= 0) builder.bearing(bearing)
            if (tilt >= 0) builder.tilt(tilt)
            com.amap.api.maps.CameraUpdateFactory.newCameraPosition(builder.build())
        } else {
            com.amap.api.maps.CameraUpdateFactory.newLatLngZoom(latLng, zoom)
        }
        if (durationMs > 0) {
            aMap.animateCamera(update, durationMs.toLong(), null)
        } else {
            aMap.animateCamera(update)
        }
    }

    /**
     * 缩放
     */
    fun zoomIn() {
        aMap.animateCamera(com.amap.api.maps.CameraUpdateFactory.zoomIn())
    }

    fun zoomOut() {
        aMap.animateCamera(com.amap.api.maps.CameraUpdateFactory.zoomOut())
    }

    fun zoomTo(level: Float, durationMs: Int = 0) {
        val update = com.amap.api.maps.CameraUpdateFactory.zoomTo(level)
        if (durationMs > 0) {
            aMap.animateCamera(update, durationMs.toLong(), null)
        } else {
            aMap.animateCamera(update)
        }
    }
}
