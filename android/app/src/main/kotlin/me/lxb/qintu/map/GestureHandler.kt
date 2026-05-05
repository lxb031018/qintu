package me.lxb.qintu.map

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.amap.api.maps.model.LatLng
import me.lxb.qintu.overlay.CarOverlay

/**
 * 手势与锁车处理器（功能模块层）
 *
 * 职责：
 * - 管理手势解锁逻辑
 * - 管理锁车跟随模式
 * - 驱动 CarOverlay 绘制
 */
class GestureHandler(
    private val cameraController: CameraController,
    private val carOverlayRef: () -> CarOverlay?,
    private val aMapHolder: AMapHolder,
    private val onMapGestureDetected: () -> Unit
) {
    companion object {
        private const val TAG = "GestureHandler"
        private const val AUTO_RELOCK_DELAY_MS = 6000L
    }

    private var isFollowMode = false
    private var isLocked = true
    private var autoRelockHandler: Handler? = null

    fun onMapTouched() {
        if (isFollowMode && isLocked) {
            isLocked = false
            autoRelockHandler?.removeCallbacksAndMessages(null)
            autoRelockHandler = Handler(Looper.getMainLooper())
            autoRelockHandler?.postDelayed({
                isLocked = true
                Log.d(TAG, "🔒 触摸超时后自动重新锁定")
            }, AUTO_RELOCK_DELAY_MS)
            Log.d(TAG, "👆 地图被触摸，解锁相机 — ${AUTO_RELOCK_DELAY_MS}ms 后自动重新锁定")
            onMapGestureDetected()
        }
    }

    fun setFollowMode(enabled: Boolean) {
        isFollowMode = enabled
        if (enabled) {
            isLocked = true
        } else {
            isLocked = false
            autoRelockHandler?.removeCallbacksAndMessages(null)
            autoRelockHandler = null
        }
        Log.d(TAG, "📍 setFollowMode: enabled=$enabled, isLocked=$isLocked")
    }

    fun setLockCar(locked: Boolean) {
        isLocked = locked
        if (!locked) {
            autoRelockHandler?.removeCallbacksAndMessages(null)
        }
        Log.d(TAG, "🔒 锁车状态: ${if (locked) "锁定" else "解锁"}")
    }

    fun updateCarMarker(lat: Double, lng: Double, bearing: Double) {
        carOverlayRef()?.draw(aMapHolder.aMap, LatLng(lat, lng), bearing.toFloat())
        if (isFollowMode && isLocked) {
            cameraController.animateCamera(lat, lng, bearing = bearing.toFloat())
        }
    }

    /**
     * 处理来自定位监听器的位置更新（仅驱动 CarOverlay，不自动跟随相机）
     */
    fun updateCarMarkerForLocation(lat: Double, lng: Double, bearing: Float) {
        carOverlayRef()?.draw(aMapHolder.aMap, LatLng(lat, lng), bearing)
    }

    fun clearCarMarker(onDestroyed: () -> Unit) {
        carOverlayRef()?.destroy()
        onDestroyed()
    }

    fun setCarOverlayVisible(visible: Boolean) {
        carOverlayRef()?.setVisible(visible)
        Log.d(TAG, "📍 车载标记: ${if (visible) "显示" else "隐藏"}")
    }

    fun setLocationDotEnabled(enabled: Boolean) {
        val aMap = aMapHolder.aMap ?: return
        if (enabled) {
            val myLocationStyle = com.amap.api.maps.model.MyLocationStyle().apply {
                showMyLocation(true)
                radiusFillColor(0x301890FF.toInt())
                strokeColor(0xFF1890FF.toInt())
                strokeWidth(2f)
                myLocationType(com.amap.api.maps.model.MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE)
                interval(2000)
            }
            aMap.myLocationStyle = myLocationStyle
        }
        aMap.isMyLocationEnabled = enabled
        Log.d(TAG, "📍 定位蓝点: ${if (enabled) "显示" else "隐藏"}")
    }
}