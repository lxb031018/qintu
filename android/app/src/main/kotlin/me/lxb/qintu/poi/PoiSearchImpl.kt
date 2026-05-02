package me.lxb.qintu.poi

import android.content.Context
import android.util.Log
import com.amap.api.services.core.AMapException
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.core.PoiItemV2
import com.amap.api.services.poisearch.PoiResultV2
import com.amap.api.services.poisearch.PoiSearchV2
import io.flutter.plugin.common.MethodChannel
import me.lxb.qintu.util.AMapPrivacy

/**
 * POI 搜索功能模块
 *
 * 封装高德搜索 SDK 的 PoiSearchV2
 */
class PoiSearchImpl(private val context: Context) {

    companion object {
        private const val TAG = "PoiSearchImpl"
    }

    private val poiCallbacks = mutableMapOf<String, MethodChannel.Result>()

    init {
        AMapPrivacy.initSearch(context)
    }

    fun searchPoi(
        keyword: String,
        city: String?,
        lat: Double?,
        lng: Double?,
        radius: Int,
        cityLimit: Boolean,
        callback: MethodChannel.Result
    ) {
        Log.d(TAG, "🔍 POI搜索: keyword=$keyword, city=$city, location=($lat,$lng), radius=$radius")

        val query = PoiSearchV2.Query(keyword, "", city ?: "")
        query.pageSize = 20
        query.cityLimit = cityLimit
        query.showFields = PoiSearchV2.ShowFields(PoiSearchV2.ShowFields.ALL)

        val search = PoiSearchV2(context, query)

        if (lat != null && lng != null) {
            val center = LatLonPoint(lat, lng)
            val bound = PoiSearchV2.SearchBound(center, radius)
            search.setBound(bound)
        }

        poiCallbacks["poi_search"] = callback

        search.setOnPoiSearchListener(object : PoiSearchV2.OnPoiSearchListener {
            override fun onPoiSearched(result: PoiResultV2?, errorCode: Int) {
                val cb = poiCallbacks.remove("poi_search")
                if (cb == null) {
                    Log.w(TAG, "⚠️ 未找到POI搜索回调")
                    return
                }
                if (errorCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val pois = result.pois?.map { serializePoi(it) } ?: emptyList()
                    Log.d(TAG, "✅ POI搜索成功: ${pois.size}条结果, 共${result.count}条")
                    if (pois.isEmpty()) {
                        Log.d(TAG, "🔍 无匹配POI结果")
                    }
                    cb.success(mapOf(
                        "pois" to pois,
                        "count" to result.count
                    ))
                } else {
                    Log.e(TAG, "❌ POI搜索失败: errorCode=$errorCode")
                    cb.error("POI_SEARCH_ERROR", "POI搜索失败: $errorCode", null)
                }
            }

            override fun onPoiItemSearched(poiItem: PoiItemV2?, errorCode: Int) {}
        })

        search.searchPOIAsyn()
    }

    fun destroy() {
        poiCallbacks.clear()
    }

    private fun serializePoi(item: PoiItemV2): Map<String, Any?> {
        val point = item.latLonPoint
        val lng = point?.longitude ?: 0.0
        val lat = point?.latitude ?: 0.0

        val subPois = item.subPois
        val entrLocation = if (subPois != null && subPois.isNotEmpty()) {
            val entryPoint = subPois[0].latLonPoint
            if (entryPoint != null) "${entryPoint.longitude},${entryPoint.latitude}" else null
        } else {
            null
        }

        return mapOf(
            "id" to (item.poiId ?: ""),
            "name" to (item.title ?: ""),
            "district" to (item.adName ?: ""),
            "address" to (item.snippet ?: ""),
            "location" to "$lng,$lat",
            "entr_location" to entrLocation,
            "cityName" to (item.cityName ?: ""),
            "provinceName" to (item.provinceName ?: ""),
            "typeDes" to (item.typeDes ?: ""),
        )
    }
}
