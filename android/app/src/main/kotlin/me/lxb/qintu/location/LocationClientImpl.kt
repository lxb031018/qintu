package me.lxb.qintu.location

import android.content.Context
import android.util.Log
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import io.flutter.plugin.common.MethodChannel

/**
 * 高德定位实现
 */
class LocationClientImpl(private val context: Context) : LocationSource {

    companion object {
        private const val TAG = "LocationClient"
    }

    private var locationClient: AMapLocationClient? = null
    private var lastKnownLocation: AMapLocation? = null
    private var isFirstLocation = true
    private var locationChangeListener: ((AMapLocation) -> Unit)? = null
    private var firstLocationListener: ((AMapLocation) -> Unit)? = null

    // 地图 LocationSource listener，用于将位置传给地图引擎
    private var mapLocationListener: com.amap.api.maps.LocationSource.OnLocationChangedListener? = null

    init {
        initLocationClient()
    }

    private fun initLocationClient() {
        try {
            locationClient = AMapLocationClient(context)
            val option = AMapLocationClientOption().apply {
                // 高精度模式（GPS + WiFi + 基站）
                locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
                // 定位间隔 2 秒
                interval = 1000
                isOnceLocation = false
                // 🔥 关键优化：开启传感器（陀螺仪 + 地磁）辅助
                isSensorEnable = true
                // ✅ 启用地址信息
                isNeedAddress = true
            }
            locationClient?.setLocationOption(option)

            locationClient?.setLocationListener { location ->
                onLocationChanged(location)
            }
            Log.d(TAG, "✅ 高德定位客户端初始化完成")
        } catch (e: Exception) {
            Log.e(TAG, "❌ 定位客户端初始化失败", e)
        }
    }

    private fun onLocationChanged(location: AMapLocation?) {
        if (location == null) return

        if (location.errorCode == 0) {
            Log.d(TAG, "📍 定位数据回调: ${location.latitude}, ${location.longitude}")

            // 存储最新位置
            lastKnownLocation = location

            // 将位置数据传给高德地图引擎（触发原生蓝点显示）
            mapLocationListener?.let { listener ->
                val stdLocation = android.location.Location(location.provider ?: "gps")
                stdLocation.latitude = location.latitude
                stdLocation.longitude = location.longitude
                stdLocation.accuracy = location.accuracy
                stdLocation.speed = location.speed
                stdLocation.time = location.time
                listener.onLocationChanged(stdLocation)
            }

            // 通知监听器
            locationChangeListener?.invoke(location)

            // 首次定位
            if (isFirstLocation) {
                isFirstLocation = false
                Log.d(TAG, "🚀 首次定位成功")
                firstLocationListener?.invoke(location)
            }
        } else {
            Log.e(TAG, "❌ 定位失败: ${location.errorCode} - ${location.errorInfo}")
        }
    }

    override fun startLocation() {
        locationClient?.startLocation()
    }

    override fun stopLocation() {
        locationClient?.stopLocation()
    }

    override fun setOnceLocation(once: Boolean) {
        val option = AMapLocationClientOption().apply {
            locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
            isOnceLocation = once
            isSensorEnable = true
            isLocationCacheEnable = false
            isNeedAddress = true
            if (!once) {
                interval = 1000
            }
        }
        locationClient?.setLocationOption(option)
    }

    override fun getLastKnownLocation(): AMapLocation? = lastKnownLocation

    override fun setLocationChangeListener(listener: (AMapLocation) -> Unit) {
        locationChangeListener = listener
    }

    override fun setFirstLocationListener(listener: (AMapLocation) -> Unit) {
        firstLocationListener = listener
    }

    override fun destroy() {
        locationClient?.onDestroy()
        locationClient = null
    }

    /**
     * 设置地图的 LocationSource listener
     * 用于将定位数据传给地图引擎
     */
    fun setMapLocationListener(listener: com.amap.api.maps.LocationSource.OnLocationChangedListener?) {
        mapLocationListener = listener
    }

    /**
     * 获取单次定位结果
     */
    fun getCurrentLocation(result: MethodChannel.Result) {
        val cacheExpireTime = 5 * 60 * 1000L // 5 分钟

        if (lastKnownLocation != null) {
            val cacheAge = System.currentTimeMillis() - lastKnownLocation!!.time
            if (cacheAge < cacheExpireTime) {
                Log.d(TAG, "✅ 使用缓存位置 (${cacheAge / 1000}秒前)")
                result.success(mapOf(
                    "latitude" to lastKnownLocation!!.latitude,
                    "longitude" to lastKnownLocation!!.longitude,
                    "accuracy" to lastKnownLocation!!.accuracy,
                    "timestamp" to lastKnownLocation!!.time,
                    "city" to (lastKnownLocation!!.city ?: "")
                ))
                return
            } else {
                Log.d(TAG, "⚠️ 缓存过期，重新定位...")
            }
        }

        Log.d(TAG, "📡 请求单次定位...")
        val onceLocationListener = object : AMapLocationListener {
            override fun onLocationChanged(location: AMapLocation?) {
                if (location != null && location.errorCode == 0) {
                    Log.d(TAG, "✅ 单次定位成功: ${location.latitude}, ${location.longitude}")
                    lastKnownLocation = location
                    result.success(mapOf(
                        "latitude" to location.latitude,
                        "longitude" to location.longitude,
                        "accuracy" to location.accuracy,
                        "timestamp" to System.currentTimeMillis(),
                        "city" to (location.city ?: "")
                    ))
                } else {
                    Log.e(TAG, "❌ 单次定位失败: ${location?.errorCode} - ${location?.errorInfo}")
                    result.error("LOCATION_ERROR", "定位失败: ${location?.errorInfo}", null)
                }
                // 恢复持续定位监听
                locationClient?.setLocationListener { loc ->
                    onLocationChanged(loc)
                }
            }
        }
        locationClient?.setLocationListener(onceLocationListener)

        // 配置单次定位
        val option = AMapLocationClientOption().apply {
            locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
            isOnceLocation = true
            isSensorEnable = true
            isLocationCacheEnable = false
            isNeedAddress = true
        }
        locationClient?.setLocationOption(option)
        locationClient?.startLocation()
    }
}
