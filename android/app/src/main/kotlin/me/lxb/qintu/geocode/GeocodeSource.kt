package me.lxb.qintu.geocode

import io.flutter.plugin.common.MethodChannel

/**
 * 地理编码功能抽象接口
 */
interface GeocodeSource {

    /**
     * 地址转坐标
     * @param address 地址字符串
     * @param callback 结果回调
     */
    fun geocodeAddress(address: String, callback: MethodChannel.Result)

    /**
     * 坐标转地址（逆地理编码）
     * @param lat 纬度
     * @param lng 经度
     * @param callback 结果回调
     */
    fun regeocode(lat: Double, lng: Double, callback: MethodChannel.Result)
}
