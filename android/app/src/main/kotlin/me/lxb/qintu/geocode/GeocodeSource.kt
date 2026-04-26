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
}
