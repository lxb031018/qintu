package me.lxb.qintu.map

import android.content.Context
import android.util.Log
import com.amap.api.maps.MapView
import com.amap.api.maps.model.MyLocationStyle
import me.lxb.qintu.location.LocationClientImpl

/**
 * 地图视图工厂
 *
 * 负责创建原生 MapView
 */
class MapViewFactory(
    private val context: Context,
    private val locationClient: LocationClientImpl,
    private val aMapHolder: AMapHolder
) {

    companion object {
        private const val TAG = "MapViewFactory"
    }

    private var locationListener: com.amap.api.maps.LocationSource.OnLocationChangedListener? = null

    /**
     * 创建原生 MapView
     */
    fun createNativeView(): MapView {
        return MapView(context)
    }

    /**
     * 配置地图
     */
    fun configureMap(mapView: MapView) {
        val aMap = mapView.map

        // 启用 AMap 自带定位蓝点
        val myLocationStyle = MyLocationStyle()
        myLocationStyle.showMyLocation(true)
        aMap.myLocationStyle = myLocationStyle
        aMap.isMyLocationEnabled = false

        // 🟢 关键步骤 1：先设置定位源
        aMap.setLocationSource(object : com.amap.api.maps.LocationSource {
            override fun activate(listener: com.amap.api.maps.LocationSource.OnLocationChangedListener?) {
                locationListener = listener
                locationClient.setMapLocationListener(listener)
                Log.d(TAG, "🔥 高德地图 LocationSource 已被激活")
            }

            override fun deactivate() {
                locationListener = null
                locationClient.setMapLocationListener(null)
                Log.d(TAG, "🔥 高德地图 LocationSource 已被取消激活")
            }
        })

        // 🟢 关键步骤 2：再开启定位功能
        aMap.isMyLocationEnabled = true

        Log.d(TAG, "🔍 地图配置完成")
    }
}
