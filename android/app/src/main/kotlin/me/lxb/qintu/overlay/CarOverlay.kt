package me.lxb.qintu.overlay

import android.content.Context
import android.graphics.BitmapFactory
import android.util.Log
import com.amap.api.maps.AMap
import com.amap.api.maps.model.BitmapDescriptor
import com.amap.api.maps.model.BitmapDescriptorFactory
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.Marker
import com.amap.api.maps.model.MarkerOptions
import me.lxb.qintu.R

class CarOverlay(context: Context) {
    companion object {
        private const val TAG = "CarOverlay"
    }

    private var carDescriptor: BitmapDescriptor? = null
    private var directionDescriptor: BitmapDescriptor? = null
    private var carMarker: Marker? = null
    private var directionMarker: Marker? = null
    private var isDirectionVisible = true
    private var isVisible = true

    init {
        carDescriptor = BitmapDescriptorFactory.fromBitmap(
            BitmapFactory.decodeResource(context.resources, R.drawable.caricon)
        )
        directionDescriptor = BitmapDescriptorFactory.fromBitmap(
            BitmapFactory.decodeResource(context.resources, R.drawable.navi_direction)
        )
        Log.d(TAG, "CarOverlay 初始化完成")
    }

    fun draw(aMap: AMap?, latLng: LatLng?, bearing: Float) {
        if (aMap == null || latLng == null || carDescriptor == null) {
            Log.w(TAG, "draw: aMap或latLng为空，跳过绘制")
            return
        }

        try {
            if (carMarker == null) {
                carMarker = aMap.addMarker(MarkerOptions()
                    .anchor(0.5f, 0.5f)
                    .setFlat(true)
                    .icon(carDescriptor)
                    .position(latLng)
                    .visible(isVisible))
            }

            if (directionMarker == null) {
                directionMarker = aMap.addMarker(MarkerOptions()
                    .anchor(0.5f, 0.5f)
                    .setFlat(true)
                    .icon(directionDescriptor)
                    .position(latLng)
                    .visible(isVisible && isDirectionVisible))
            }

            carMarker?.apply {
                position = latLng
                rotateAngle = 360 - bearing
                isFlat = true
                isVisible = this@CarOverlay.isVisible
            }

            directionMarker?.apply {
                position = latLng
                rotateAngle = 360 - bearing
                isVisible = this@CarOverlay.isVisible && this@CarOverlay.isDirectionVisible
            }

            Log.v(TAG, String.format("📍 自车位置更新: (%.6f, %.6f), 方向: %.1f°",
                latLng.latitude, latLng.longitude, bearing))

        } catch (e: Throwable) {
            Log.e(TAG, "绘制自车失败: ${e.message}")
        }
    }

    fun setDirectionVisible(visible: Boolean) {
        isDirectionVisible = visible
        directionMarker?.isVisible = visible
    }

    fun setVisible(visible: Boolean) {
        isVisible = visible
        carMarker?.isVisible = visible
        directionMarker?.isVisible = visible && isDirectionVisible
    }

    fun destroy() {
        carMarker?.remove()
        carMarker = null
        directionMarker?.remove()
        directionMarker = null
        carDescriptor = null
        directionDescriptor = null
        Log.d(TAG, "CarOverlay 资源已释放")
    }
}