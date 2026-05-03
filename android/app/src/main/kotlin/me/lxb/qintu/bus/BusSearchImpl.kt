package me.lxb.qintu.bus

import android.content.Context
import android.util.Log
import com.amap.api.services.busline.BusLineItem
import com.amap.api.services.busline.BusLineQuery
import com.amap.api.services.busline.BusLineResult
import com.amap.api.services.busline.BusLineSearch
import com.amap.api.services.busline.BusStationItem
import com.amap.api.services.busline.BusStationQuery
import com.amap.api.services.busline.BusStationResult
import com.amap.api.services.busline.BusStationSearch
import com.amap.api.services.core.AMapException
import io.flutter.plugin.common.MethodChannel
import me.lxb.qintu.util.AMapPrivacy
import me.lxb.qintu.util.toCoordinateMap
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.concurrent.atomic.AtomicInteger

/**
 * 公交搜索功能模块
 *
 * 封装高德搜索 SDK 的 BusStationSearch / BusLineSearch
 */
class BusSearchImpl(context: Context) {

    companion object {
        private const val TAG = "BusSearchImpl"
        private const val DATE_FORMAT = "HHmm"
    }

    private val stationCallbacks = mutableMapOf<String, MethodChannel.Result>()
    private val lineCallbacks = mutableMapOf<Int, MethodChannel.Result>()

    private val lineRequestId = AtomicInteger(0)

    private val busStationSearch: BusStationSearch = BusStationSearch(context, BusStationQuery("", ""))
    private val busLineSearch: BusLineSearch = BusLineSearch(context, BusLineQuery("", BusLineQuery.SearchType.BY_LINE_NAME, ""))

    init {
        AMapPrivacy.initSearch(context)

        busStationSearch.setOnBusStationSearchListener(object : BusStationSearch.OnBusStationSearchListener {
            override fun onBusStationSearched(result: BusStationResult?, rCode: Int) {
                val requestId = "station_search"
                val callback = stationCallbacks.remove(requestId)
                if (callback == null) {
                    Log.w(TAG, "⚠️ 未找到站台搜索回调")
                    return
                }
                if (rCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val stations = result.busStations.map { serializeStation(it) }
                    callback.success(mapOf(
                        "stations" to stations,
                        "pageCount" to result.pageCount,
                        "suggestionKeywords" to (result.searchSuggestionKeywords ?: emptyList<String>()),
                        "suggestionCities" to result.searchSuggestionCities.map { it.cityName ?: "" }
                    ))
                } else {
                    Log.e(TAG, "❌ 站台搜索失败: rCode=$rCode")
                    callback.error("BUS_STATION_ERROR", "站台搜索失败: $rCode", null)
                }
            }
        })

        busLineSearch.setOnBusLineSearchListener(object : BusLineSearch.OnBusLineSearchListener {
            override fun onBusLineSearched(result: BusLineResult?, rCode: Int) {
                val entry = lineCallbacks.entries.firstOrNull()
                if (entry == null) {
                    Log.w(TAG, "⚠️ 未找到线路搜索回调")
                    return
                }
                val callback = lineCallbacks.remove(entry.key)
                if (callback == null) {
                    Log.w(TAG, "⚠️ 线路搜索回调已被移除")
                    return
                }
                if (rCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val lines = result.busLines.map { serializeLineDetail(it) }
                    callback.success(mapOf(
                        "lines" to lines,
                        "pageCount" to result.pageCount,
                        "suggestionKeywords" to (result.searchSuggestionKeywords ?: emptyList<String>()),
                        "suggestionCities" to result.searchSuggestionCities.map { it.cityName ?: "" }
                    ))
                } else {
                    Log.e(TAG, "❌ 线路搜索失败: rCode=$rCode")
                    callback.error("BUS_LINE_ERROR", "线路搜索失败: $rCode", null)
                }
            }
        })
    }

    fun searchBusStation(keyword: String, city: String, callback: MethodChannel.Result) {
        Log.d(TAG, "🔍 搜索公交站: keyword=$keyword, city=$city")
        stationCallbacks["station_search"] = callback
        val query = BusStationQuery(keyword, city)
        busStationSearch.query = query
        busStationSearch.searchBusStationAsyn()
    }

    fun searchBusLineByName(keyword: String, city: String, callback: MethodChannel.Result) {
        Log.d(TAG, "🔍 按名称搜索公交线路: keyword=$keyword, city=$city")
        val requestId = lineRequestId.incrementAndGet()
        lineCallbacks[requestId] = callback
        val query = BusLineQuery(keyword, BusLineQuery.SearchType.BY_LINE_NAME, city)
        query.extensions = BusLineSearch.EXTENSIONS_ALL
        busLineSearch.query = query
        busLineSearch.searchBusLineAsyn()
    }

    fun searchBusLineById(lineId: String, city: String, callback: MethodChannel.Result) {
        Log.d(TAG, "🔍 按ID搜索公交线路: lineId=$lineId, city=$city")
        val requestId = lineRequestId.incrementAndGet()
        lineCallbacks[requestId] = callback
        val query = BusLineQuery(lineId, BusLineQuery.SearchType.BY_LINE_ID, city)
        query.extensions = BusLineSearch.EXTENSIONS_ALL
        busLineSearch.query = query
        busLineSearch.searchBusLineAsyn()
    }

    fun destroy() {
        stationCallbacks.clear()
        lineCallbacks.clear()
    }

    // ==================== 站台/线路序列化 ====================

    private fun serializeStation(item: BusStationItem): Map<String, Any?> {
        val lines = item.busLineItems?.map { serializeLineBrief(it) } ?: emptyList()
        val point = item.latLonPoint
        return mapOf(
            "id" to (item.busStationId ?: ""),
            "name" to (item.busStationName ?: ""),
            "lat" to (point?.latitude ?: 0.0),
            "lng" to (point?.longitude ?: 0.0),
            "cityCode" to (item.cityCode ?: ""),
            "adCode" to (item.adCode ?: ""),
            "busLines" to lines
        )
    }

    private fun serializeLineBrief(item: BusLineItem): Map<String, Any?> {
        return mapOf(
            "id" to (item.busLineId ?: ""),
            "name" to (item.busLineName ?: ""),
            "type" to (item.busLineType ?: "")
        )
    }

    private fun serializeLineDetail(item: BusLineItem): Map<String, Any?> {
        val stations = item.busStations?.map { station ->
            val point = station.latLonPoint
            mapOf(
                "id" to (station.busStationId ?: ""),
                "name" to (station.busStationName ?: ""),
                "lat" to (point?.latitude ?: 0.0),
                "lng" to (point?.longitude ?: 0.0)
            )
        } ?: emptyList()

        val coords = item.directionsCoordinates?.map { it.toCoordinateMap() } ?: emptyList()

        val firstTime = formatBusTime(item.firstBusTime)
        val lastTime = formatBusTime(item.lastBusTime)

        return mapOf(
            "id" to (item.busLineId ?: ""),
            "name" to (item.busLineName ?: ""),
            "type" to (item.busLineType ?: ""),
            "cityCode" to (item.cityCode ?: ""),
            "originStation" to (item.originatingStation ?: ""),
            "terminalStation" to (item.terminalStation ?: ""),
            "distance" to item.distance.toDouble(),
            "basicPrice" to item.basicPrice.toDouble(),
            "totalPrice" to item.totalPrice.toDouble(),
            "company" to (item.busCompany ?: ""),
            "firstBusTime" to firstTime,
            "lastBusTime" to lastTime,
            "stations" to stations,
            "coordinates" to coords
        )
    }

    private fun formatBusTime(date: java.util.Date?): String {
        return try {
            date?.let { SimpleDateFormat(DATE_FORMAT, Locale.getDefault()).format(it) } ?: ""
        } catch (e: Exception) {
            ""
        }
    }
}
