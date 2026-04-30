package me.lxb.qintu.geocode

import android.content.Context
import android.util.Log
import com.amap.api.services.core.AMapException
import com.amap.api.services.core.ServiceSettings
import com.amap.api.services.geocoder.GeocodeQuery
import com.amap.api.services.geocoder.GeocodeResult
import com.amap.api.services.geocoder.GeocodeSearch
import com.amap.api.services.geocoder.RegeocodeResult
import io.flutter.plugin.common.MethodChannel

/**
 * 地理编码实现
 */
class GeocodeImpl(context: Context) : GeocodeSource {

    companion object {
        private const val TAG = "GeocodeImpl"
    }

    private val geocodeCallbacks = mutableMapOf<String, MethodChannel.Result>()
    private val geocodeSearch: GeocodeSearch = GeocodeSearch(context)

    init {
        // 搜索 SDK 必须单独设置隐私合规（不同于地图 SDK 的 MapsInitializer）
        ServiceSettings.updatePrivacyShow(context, true, true)
        ServiceSettings.updatePrivacyAgree(context, true)

        geocodeSearch.setOnGeocodeSearchListener(object : GeocodeSearch.OnGeocodeSearchListener {
            override fun onGeocodeSearched(result: GeocodeResult?, rCode: Int) {
                if (rCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val geocodes = result.geocodeAddressList
                    if (geocodes != null && geocodes.isNotEmpty()) {
                        val first = geocodes[0]
                        val latLng = first.latLonPoint
                        Log.d(TAG, "✅ 地理编码成功: ${first.formatAddress} → ${latLng.latitude}, ${latLng.longitude}")
                        val callback = geocodeCallbacks.values.firstOrNull()
                        if (callback != null) {
                            callback.success(mapOf(
                                "latitude" to latLng.latitude,
                                "longitude" to latLng.longitude,
                                "address" to first.formatAddress
                            ))
                            geocodeCallbacks.clear()
                        }
                    } else {
                        Log.w(TAG, "⚠️ 地理编码无结果")
                        val callback = geocodeCallbacks.values.firstOrNull()
                        callback?.error("GEOCODE_NO_RESULT", "未找到匹配的地址", null)
                        geocodeCallbacks.clear()
                    }
                } else {
                    Log.e(TAG, "❌ 地理编码失败: $rCode")
                    val callback = geocodeCallbacks.values.firstOrNull()
                    callback?.error("GEOCODE_ERROR", "地理编码失败: $rCode", null)
                    geocodeCallbacks.clear()
                }
            }

            override fun onRegeocodeSearched(result: RegeocodeResult?, rCode: Int) {
                // 逆地理编码（坐标转地址），暂不使用
            }
        })
    }

    override fun geocodeAddress(address: String, callback: MethodChannel.Result) {
        Log.d(TAG, "🗺️ 开始地理编码: $address")
        geocodeCallbacks["current"] = callback

        val query = GeocodeQuery(address, "010") // 010 是全国城市代码
        geocodeSearch.getFromLocationNameAsyn(query)
    }
}
