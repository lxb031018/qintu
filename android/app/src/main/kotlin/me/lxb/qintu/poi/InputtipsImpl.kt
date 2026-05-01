package me.lxb.qintu.poi

import android.content.Context
import android.util.Log
import com.amap.api.services.core.AMapException
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.help.Inputtips
import com.amap.api.services.help.InputtipsQuery
import com.amap.api.services.help.Tip
import io.flutter.plugin.common.MethodChannel

/**
 * 输入提示功能模块
 *
 * 封装高德搜索 SDK 的 Inputtips（输入联想/模糊匹配）
 */
class InputtipsImpl(private val context: Context) {

    companion object {
        private const val TAG = "InputtipsImpl"
    }

    private val tipsCallbacks = mutableMapOf<String, MethodChannel.Result>()
    private var tipsIdCounter = 0

    fun searchInputtips(
        keyword: String,
        city: String?,
        lat: Double?,
        lng: Double?,
        callback: MethodChannel.Result
    ) {
        Log.d(TAG, "🔍 输入提示: keyword=$keyword, city=$city, location=($lat,$lng)")

        val query = InputtipsQuery(keyword, city ?: "")

        if (lat != null && lng != null) {
            query.location = LatLonPoint(lat, lng)
        }

        val inputtips = Inputtips(context, query)
        val requestId = "tips_${++tipsIdCounter}"
        tipsCallbacks[requestId] = callback

        inputtips.setInputtipsListener { tips, resultId ->
            val cb = tipsCallbacks.remove(requestId)
            if (cb == null) {
                Log.w(TAG, "⚠️ 未找到输入提示回调")
                return@setInputtipsListener
            }

            if (resultId == AMapException.CODE_AMAP_SUCCESS && tips != null) {
                val serialized = tips.map { serializeTip(it) }
                Log.d(TAG, "✅ 输入提示成功: ${serialized.size}条结果")
                cb.success(mapOf("tips" to serialized))
            } else {
                Log.e(TAG, "❌ 输入提示失败: rCode=$resultId")
                cb.error("INPUTTIPS_ERROR", "输入提示失败: $resultId", null)
            }
        }

        inputtips.requestInputtipsAsyn()
    }

    fun destroy() {
        tipsCallbacks.clear()
    }

    private fun serializeTip(tip: Tip): Map<String, Any?> {
        val point = tip.point
        val lat = point?.latitude ?: 0.0
        val lng = point?.longitude ?: 0.0

        return mapOf(
            "name" to (tip.name ?: ""),
            "district" to (tip.district ?: ""),
            "adcode" to (tip.adcode ?: ""),
            "address" to (tip.address ?: ""),
            "poiId" to (tip.poiID ?: ""),
            "latitude" to lat,
            "longitude" to lng,
        )
    }
}
