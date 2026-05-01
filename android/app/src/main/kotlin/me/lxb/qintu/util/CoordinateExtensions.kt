package me.lxb.qintu.util

import com.amap.api.maps.model.LatLng
import com.amap.api.navi.model.NaviLatLng
import com.amap.api.services.core.LatLonPoint

fun LatLng.toCoordinateMap() = mapOf("lat" to latitude, "lng" to longitude)

fun LatLonPoint.toCoordinateMap() = mapOf("lat" to latitude, "lng" to longitude)

fun NaviLatLng.toCoordinateMap() = mapOf("lat" to latitude, "lng" to longitude)
