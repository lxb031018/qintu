package me.lxb.qintu.map

import android.util.Log
import com.amap.api.maps.AMap
import com.amap.api.maps.model.CameraPosition
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.LatLngBounds

/**
 * 相机控制器
 */
class CameraController(private val aMap: AMap) {

    companion object {
        private const val TAG = "CameraController"
        private const val DEFAULT_ZOOM = 17f
    }

    private var viewWidth: Int = 0
    private var viewHeight: Int = 0

    fun setViewSize(width: Int, height: Int) {
        viewWidth = width
        viewHeight = height
    }

    fun isViewSizeReady(): Boolean = viewWidth > 0 && viewHeight > 0

    private fun resetCenterPoint() {
        if (viewWidth > 0 && viewHeight > 0) {
            aMap.setPointToCenter(viewWidth / 2, viewHeight / 2)
        } else {
            Log.w(TAG, "⚠️ resetCenterPoint: 视图尺寸未就绪 (${viewWidth}x${viewHeight}), 使用默认值")
            aMap.setPointToCenter(200, 200)
        }
    }

    /**
     * 移动相机到指定位置（瞬间跳转）
     */
    fun moveCamera(lat: Double, lng: Double, zoom: Float = DEFAULT_ZOOM,
                   bearing: Float = -1f, tilt: Float = -1f) {
        resetCenterPoint()
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
     * 移动相机到指定位置，并以屏幕正中央为目标点。
     *
     * 先调用 setPointToCenter 重置中心点为视图像素中心，
     * 再执行 moveCamera，解决 AMapNaviView 内部锚点偏移问题。
     */
    fun moveCameraToCenter(lat: Double, lng: Double, zoom: Float = DEFAULT_ZOOM) {
        if (viewWidth > 0 && viewHeight > 0) {
            aMap.setPointToCenter(viewWidth / 2, viewHeight / 2)
        } else {
            Log.w(TAG, "⚠️ moveCameraToCenter: viewSize 未就绪 (${viewWidth}x${viewHeight}), 使用默认中心点")
            aMap.setPointToCenter(viewWidth.coerceAtLeast(200), viewHeight.coerceAtLeast(200))
        }
        Log.d(TAG, "🎯 moveCameraToCenter: lat=$lat, lng=$lng, zoom=$zoom (center=${viewWidth/2},${viewHeight/2})")
        val latLng = LatLng(lat, lng)
        aMap.moveCamera(com.amap.api.maps.CameraUpdateFactory.newLatLngZoom(latLng, zoom))
    }

    /**
     * 平滑动画移动相机到指定位置，并以屏幕正中央为目标点。
     */
    fun animateCameraToCenter(lat: Double, lng: Double, zoom: Float = DEFAULT_ZOOM,
                              durationMs: Int = 500) {
        resetCenterPoint()
        Log.d(TAG, "🎯 animateCameraToCenter: lat=$lat, lng=$lng, zoom=$zoom, duration=$durationMs")
        val latLng = LatLng(lat, lng)
        val update = com.amap.api.maps.CameraUpdateFactory.newLatLngZoom(latLng, zoom)
        if (durationMs > 0) {
            aMap.animateCamera(update, durationMs.toLong(), null)
        } else {
            aMap.animateCamera(update)
        }
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
     * 自动计算缩放级别，平滑动画移动相机以显示所有坐标点
     *
     * @param points 坐标点列表
     * @param padding 边缘留白（像素）
     * @param durationMs 动画时长（毫秒）
     */
    fun animateCameraToBounds(points: List<LatLng>, padding: Int = 100, durationMs: Int = 500) {
        if (points.isEmpty()) {
            Log.w(TAG, "⚠️ animateCameraToBounds: 坐标列表为空")
            return
        }
        val boundsBuilder = LatLngBounds.Builder()
        for (point in points) {
            boundsBuilder.include(point)
        }
        val bounds = boundsBuilder.build()
        Log.d(TAG, "🎥 animateCameraToBounds: ${points.size} 个点, padding=$padding, duration=$durationMs")
        val update = com.amap.api.maps.CameraUpdateFactory.newLatLngBounds(bounds, padding)
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

    /**
     * 设置屏幕上的某个像素点为地图中心点。
     */
    fun setPointToCenter(x: Int, y: Int) {
        Log.d(TAG, "🎯 setPointToCenter: x=$x, y=$y")
        aMap.setPointToCenter(x, y)
    }
}
