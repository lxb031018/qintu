package me.lxb.qintu

import android.content.Context
import android.util.Log
import android.view.View
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.maps.AMap
import com.amap.api.maps.MapView
import com.amap.api.maps.MapsInitializer
import com.amap.api.maps.model.MyLocationStyle
import com.amap.api.services.core.AMapException
import com.amap.api.services.geocoder.GeocodeQuery
import com.amap.api.services.geocoder.GeocodeResult
import com.amap.api.services.geocoder.GeocodeSearch
import com.amap.api.services.geocoder.RegeocodeResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

/**
 * 高德地图 PlatformView 插件
 * 
 * 使用高德原生定位 SDK + 原生定位蓝点（箭头样式）
 */
class AmapMapPlugin : FlutterPlugin, MethodCallHandler {

    companion object {
        private const val TAG = "AmapMap"
        private const val VIEW_TYPE = "com.qintu/amap_map_view"
        private const val CHANNEL = "com.qintu/amap_map_control"
    }

    private var aMap: AMap? = null
    private var locationClient: AMapLocationClient? = null
    private var geocodeSearch: GeocodeSearch? = null
    private var context: Context? = null
    private var locationListener: com.amap.api.maps.LocationSource.OnLocationChangedListener? = null

    private var isFirstLocation = true // 标记是否首次定位
    private var lastKnownLocation: AMapLocation? = null // 存储最近一次成功定位的位置

    // 地理编码回调存储
    private val geocodeCallbacks = mutableMapOf<String, Result>()

    // 路线覆盖层存储（支持多条路线）
    private val routeOverlays = mutableListOf<com.amap.api.maps.model.Polyline>()
    private var selectedRouteIndex = -1 // 当前选中的路线索引

    // 起点/终点标记
    private var startMarker: com.amap.api.maps.model.Marker? = null
    private var endMarker: com.amap.api.maps.model.Marker? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        // ✅ 必须：设置高德地图隐私合规
        MapsInitializer.updatePrivacyShow(context!!, true, true)
        MapsInitializer.updatePrivacyAgree(context!!, true)

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            VIEW_TYPE,
            object : PlatformViewFactory(StandardMessageCodec()) {
                override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
                    return createMapView(context, viewId)
                }
            }
        )

        val channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)

        // 初始化定位客户端
        initLocationClient()
        
        // 初始化地理编码搜索
        geocodeSearch = GeocodeSearch(context!!)
        geocodeSearch?.setOnGeocodeSearchListener(object : GeocodeSearch.OnGeocodeSearchListener {
            override fun onGeocodeSearched(result: GeocodeResult?, rCode: Int) {
                if (rCode == AMapException.CODE_AMAP_SUCCESS && result != null) {
                    val geocodes = result.geocodeAddressList
                    if (geocodes != null && geocodes.isNotEmpty()) {
                        val first = geocodes[0]
                        val latLng = first.latLonPoint
                        Log.d(TAG, "✅ 地理编码成功: ${first.formatAddress} → ${latLng.latitude}, ${latLng.longitude}")
                        // 找到匹配的回调
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

    private fun initLocationClient() {
        try {
            locationClient = AMapLocationClient(context)
            val option = AMapLocationClientOption().apply {
                // 高精度模式（GPS + WiFi + 基站）
                locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
                // 定位间隔 2 秒
                interval = 2000
                isOnceLocation = false
                // 🔥 关键优化：开启传感器（陀螺仪 + 地磁）辅助
                // 作用：解决静止或慢走时方向不准的问题，让箭头像指南针一样灵敏
                isSensorEnable = true
                // ✅ 启用地址信息（城市、区县等），用于 POI 搜索城市限制
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
            Log.d(TAG, "🔍 精度: ${location.accuracy}米, 方向: ${location.bearing}")
            Log.d(TAG, "🔍 [关键] 当前 locationListener 状态: ${if (locationListener != null) "✅ 已激活" else "❌ 为 NULL"}")
            
            // 存储最新位置
            lastKnownLocation = location
            
            // 🔴 关键：将位置数据传给高德地图引擎（触发原生蓝点显示）
            locationListener?.let { listener ->
                // 高德地图引擎需要标准的 android.location.Location 对象
                val stdLocation = android.location.Location(location.provider ?: "gps")
                stdLocation.latitude = location.latitude
                stdLocation.longitude = location.longitude
                stdLocation.accuracy = location.accuracy
                // stdLocation.bearing = location.bearing  <-- 🔴 注释掉这行！
                // 让地图组件自己去读取手机的陀螺仪和指南针，方向会更准、更灵敏
                stdLocation.speed = location.speed
                stdLocation.time = location.time
                
                Log.d(TAG, "🚀 发送位置给地图引擎 (Listener)")
                listener.onLocationChanged(stdLocation)
            }
            
            // ✅ 首次定位成功后，移动地图到当前位置
            if (isFirstLocation) {
                isFirstLocation = false
                Log.d(TAG, "🚀 首次定位成功，移动相机")
                moveCameraToLocation(location.latitude, location.longitude)
            }
        } else {
            Log.e(TAG, "❌ 定位失败: ${location.errorCode} - ${location.errorInfo}")
        }
    }

    /**
     * 移动地图相机到指定位置
     */
    private fun moveCameraToLocation(lat: Double, lng: Double, zoom: Float = 17f) {
        aMap?.let { map ->
            val latLng = com.amap.api.maps.model.LatLng(lat, lng)
            Log.d(TAG, "🎥 移动相机到: lat=$lat, lng=$lng, zoom=$zoom")
            map.moveCamera(
                com.amap.api.maps.CameraUpdateFactory.newLatLngZoom(latLng, zoom)
            )
        }
    }

    private fun createMapView(context: Context, viewId: Int): PlatformView {
        return object : PlatformView {
            private val view: MapView = MapView(context).apply {
                onCreate(null)
                onResume()
            }

            init {
                aMap = view.map
                aMap?.apply {
                    // ✅ 配置原生定位蓝点样式（箭头样式，跟随旋转）
                    val myLocationStyle = MyLocationStyle()
                    // 连续定位，蓝点居中，箭头跟随方向旋转
                    myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER)
                    myLocationStyle.interval(2000)
                    myLocationStyle.showMyLocation(true)
                    // 设置蓝点样式（可选）
                    myLocationStyle.radiusFillColor(0x401890FF.toInt())
                    myLocationStyle.strokeColor(0x801890FF.toInt())
                    myLocationStyle.strokeWidth(3f)
                    
                    this.myLocationStyle = myLocationStyle

                    // 基础 UI 设置
                    uiSettings.isZoomControlsEnabled = false
                    uiSettings.isMyLocationButtonEnabled = false

                    // 🟢 关键步骤 1：先设置定位源
                    setLocationSource(object : com.amap.api.maps.LocationSource {
                        override fun activate(listener: com.amap.api.maps.LocationSource.OnLocationChangedListener?) {
                            locationListener = listener
                            Log.d(TAG, "🔥 [关键] 高德地图 LocationSource 已被激活！")
                        }
                        override fun deactivate() {
                            locationListener = null
                            Log.d(TAG, "🔥 [关键] 高德地图 LocationSource 已被取消激活")
                        }
                    })

                    // 🟢 关键步骤 2：再开启定位功能
                    isMyLocationEnabled = true
                    
                    Log.d(TAG, "🔍 地图初始化: isMyLocationEnabled=$isMyLocationEnabled")
                }
                Log.d(TAG, "🗺️ 地图视图 #$viewId 初始化完成")
            }

            override fun getView(): View = view

            override fun dispose() {
                view.onDestroy()
                stopLocation()
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startLocation" -> {
                Log.d(TAG, "📡 收到 startLocation 调用")
                locationClient?.startLocation()
                result.success(true)
            }
            "moveToMyLocation" -> {
                Log.d(TAG, "🎯 收到 moveToMyLocation 调用")
                if (lastKnownLocation != null) {
                    moveCameraToLocation(lastKnownLocation!!.latitude, lastKnownLocation!!.longitude)
                    result.success(true)
                } else {
                    Log.d(TAG, "📡 尚无已知位置，请求单次定位...")
                    val option = AMapLocationClientOption().apply {
                        locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
                        isOnceLocation = true
                    }
                    locationClient?.setLocationOption(option)
                    locationClient?.startLocation()
                    result.success(false)
                }
            }
            "getCurrentLocation" -> {
                Log.d(TAG, "📍 收到 getCurrentLocation 调用")
                getCurrentLocation(result)
            }
            "geocodeAddress" -> {
                val address = call.argument<String>("address")
                if (address.isNullOrEmpty()) {
                    result.error("INVALID_ADDRESS", "地址不能为空", null)
                } else {
                    Log.d(TAG, "📍 收到 geocodeAddress 调用: $address")
                    geocodeAddress(address, result)
                }
            }
            "calculateDistance" -> {
                // 使用高德 AMapUtils.calculateLineDistance 计算两点间距离
                val fromLat = call.argument<Double>("fromLat")
                val fromLng = call.argument<Double>("fromLng")
                val toLat = call.argument<Double>("toLat")
                val toLng = call.argument<Double>("toLng")
                if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
                    result.error("INVALID_PARAMS", "坐标参数不能为空", null)
                } else {
                    val from = com.amap.api.maps.model.LatLng(fromLat, fromLng)
                    val to = com.amap.api.maps.model.LatLng(toLat, toLng)
                    val distance = com.amap.api.maps.AMapUtils.calculateLineDistance(from, to)
                    Log.d(TAG, "📏 计算距离: $from → $to = ${distance}米")
                    result.success(distance.toInt())
                }
            }
            "showRoutes" -> {
                // 显示多条路线
                val routesData = call.argument<List<*>>("routes")
                val selectIndex = call.argument<Int>("selectIndex") ?: 0
                Log.d(TAG, "📍 收到 showRoutes 调用: ${routesData?.size} 条路线, 选中: $selectIndex")
                showRoutes(routesData, selectIndex, result)
            }
            "selectRoute" -> {
                // 选择高亮某条路线
                val index = call.argument<Int>("index") ?: 0
                Log.d(TAG, "📍 收到 selectRoute 调用: index=$index")
                selectRoute(index, result)
            }
            "clearRoutes" -> {
                // 清除所有路线
                Log.d(TAG, "📍 收到 clearRoutes 调用")
                clearRoutes()
                result.success(true)
            }
            "setRouteMarkers" -> {
                // 设置路线起点/终点标记
                val startLat = call.argument<Double>("startLat")
                val startLng = call.argument<Double>("startLng")
                val endLat = call.argument<Double>("endLat")
                val endLng = call.argument<Double>("endLng")
                val startLabel = call.argument<String>("startLabel") ?: "起点"
                val endLabel = call.argument<String>("endLabel") ?: "终点"
                Log.d(TAG, "📍 收到 setRouteMarkers 调用: start=($startLat,$startLng), end=($endLat,$endLng)")
                setRouteMarkers(startLat, startLng, endLat, endLng, startLabel, endLabel, result)
            }
            "clearRouteMarkers" -> {
                // 清除路线标记
                Log.d(TAG, "📍 收到 clearRouteMarkers 调用")
                clearRouteMarkers()
                result.success(true)
            }
            "moveCamera" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val zoom = call.argument<Double>("zoom") ?: 15.0
                if (lat != null && lng != null) {
                    moveCameraToLocation(lat, lng, zoom.toFloat())
                    result.success(true)
                } else {
                    result.error("INVALID_PARAMS", "lat/lng 不能为空", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    /**
     * 获取当前位置
     * 如果缓存位置在 5 分钟内直接返回，否则重新定位
     */
    private fun getCurrentLocation(result: Result) {
        val cacheExpireTime = 5 * 60 * 1000L // 5 分钟
        
        if (lastKnownLocation != null) {
            val cacheAge = System.currentTimeMillis() - lastKnownLocation!!.time
            if (cacheAge < cacheExpireTime) {
                Log.d(TAG, "✅ 使用缓存位置 (${cacheAge / 1000}秒前): ${lastKnownLocation!!.latitude}, ${lastKnownLocation!!.longitude}")
                result.success(mapOf(
                    "latitude" to lastKnownLocation!!.latitude,
                    "longitude" to lastKnownLocation!!.longitude,
                    "accuracy" to lastKnownLocation!!.accuracy,
                    "timestamp" to lastKnownLocation!!.time,
                    "city" to (lastKnownLocation!!.city ?: "")
                ))
                return
            } else {
                Log.d(TAG, "⚠️ 缓存过期 (${cacheAge / 1000}秒前)，重新定位...")
            }
        }
        
        Log.d(TAG, "📡 请求单次定位...")
        // 设置单次定位回调
        val onceLocationListener = object : com.amap.api.location.AMapLocationListener {
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
                // 恢复持续定位
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
            // 强制使用 GPS + 网络定位，提高精度
            isLocationCacheEnable = false
            // ✅ 启用地址信息（城市、区县等），用于 POI 搜索城市限制
            isNeedAddress = true
        }
        locationClient?.setLocationOption(option)
        locationClient?.startLocation()
    }

    /**
     * 地理编码：地址转坐标
     */
    private fun geocodeAddress(address: String, result: Result) {
        Log.d(TAG, "🗺️ 开始地理编码: $address")
        geocodeCallbacks["current"] = result

        val query = GeocodeQuery(address, "010") // 010 是全国城市代码
        geocodeSearch?.getFromLocationNameAsyn(query)
    }

    /**
     * 显示多条路线
     * routesData: List of routes, each route is a List of [lat, lng] pairs
     * selectIndex: which route to highlight
     */
    private fun showRoutes(routesData: List<*>?, selectIndex: Int, result: Result) {
        Log.d(TAG, "🗺️ [Native] showRoutes 开始执行")
        Log.d(TAG, "🗺️ [Native] 接收到的 routesData: $routesData")
        Log.d(TAG, "🗺️ [Native] 接收到的 selectIndex: $selectIndex")

        if (aMap == null) {
            Log.e(TAG, "❌ [Native] 地图未初始化!")
            result.error("MAP_NOT_READY", "地图未初始化", null)
            return
        }

        // 清除旧路线
        Log.d(TAG, "🗺️ [Native] 清除旧路线...")
        clearRoutes()

        if (routesData == null || routesData.isEmpty()) {
            Log.w(TAG, "⚠️ [Native] routesData 为空或 null")
            result.success(0)
            return
        }

        Log.d(TAG, "🗺️ [Native] 开始遍历 ${routesData.size} 条路线")

        // 路线颜色配置（选中为蓝色，其余为浅灰色）
        val selectedColor = 0xFF1890FF.toInt() // 蓝色
        val unselectedColor = 0xFF999999.toInt() // 灰色

        var successCount = 0
        for ((index, routeData) in routesData.withIndex()) {
            Log.d(TAG, "🗺️ [Native] 处理路线 $index, 类型: ${routeData?.javaClass?.simpleName}")
            try {
                val points = mutableListOf<com.amap.api.maps.model.LatLng>()

                if (routeData is List<*>) {
                    Log.d(TAG, "🗺️ [Native] 路线 $index 是 List, 包含 ${routeData.size} 个元素")
                    for (point in routeData) {
                        if (point is Map<*, *>) {
                            val lat = (point["lat"] as? Number)?.toDouble() ?: continue
                            val lng = (point["lng"] as? Number)?.toDouble() ?: continue
                            points.add(com.amap.api.maps.model.LatLng(lat, lng))
                        } else {
                            Log.w(TAG, "⚠️ [Native] 路线 $index 中发现非 Map 元素: ${point?.javaClass?.simpleName}")
                        }
                    }
                } else {
                    Log.e(TAG, "❌ [Native] 路线 $index 不是 List 类型: ${routeData?.javaClass?.simpleName}")
                    continue
                }

                Log.d(TAG, "🗺️ [Native] 路线 $index 解析后有 ${points.size} 个点")

                if (points.size < 2) {
                    Log.w(TAG, "⚠️ [Native] 路线 $index 点数不足 (<2), 跳过")
                    continue
                }

                val isSelected = index == selectIndex
                Log.d(TAG, "🗺️ [Native] 路线 $index: isSelected=$isSelected, 颜色=${if (isSelected) "选中色" else "未选中色"}")

                val polyline = aMap!!.addPolyline(
                    com.amap.api.maps.model.PolylineOptions()
                        .addAll(points)
                        .color(if (isSelected) selectedColor else unselectedColor)
                        .width(if (isSelected) 12f else 8f)
                )

                routeOverlays.add(polyline)
                successCount++
                Log.d(TAG, "✅ [Native] 成功添加路线 $index: ${points.size} 个点, ${if (isSelected) "选中" else "未选中"}")
            } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 添加路线 $index 失败: ${e.message}")
            }
        }

        Log.d(TAG, "🗺️ [Native] 共成功添加 $successCount 条路线")

        selectedRouteIndex = selectIndex
        Log.d(TAG, "🗺️ [Native] selectedRouteIndex 设置为 $selectIndex")

        // 移动相机到路线起点
        if (routeOverlays.isNotEmpty() && selectIndex < routeOverlays.size) {
            val polyline = routeOverlays[selectIndex]
            val points = polyline.points
            if (points.isNotEmpty()) {
                Log.d(TAG, "🗺️ [Native] 移动相机到路线 $selectIndex 的范围")
                aMap!!.moveCamera(
                    com.amap.api.maps.CameraUpdateFactory.newLatLngBounds(
                        com.amap.api.maps.model.LatLngBounds.builder()
                            .include(points.first())
                            .include(points.last())
                            .build(),
                        100
                    )
                )
            }
        } else {
            Log.w(TAG, "⚠️ [Native] 无法移动相机: routeOverlays.size=${routeOverlays.size}, selectIndex=$selectIndex")
        }

        Log.d(TAG, "🗺️ [Native] showRoutes 执行完成, 返回 $successCount 条路线")
        result.success(routeOverlays.size)
    }

    /**
     * 选择高亮某条路线
     */
    private fun selectRoute(index: Int, result: Result) {
        Log.d(TAG, "🗺️ [Native] selectRoute 开始执行: index=$index")
        Log.d(TAG, "🗺️ [Native] 当前 routeOverlays.size=${routeOverlays.size}")

        if (aMap == null) {
            Log.e(TAG, "❌ [Native] aMap 为 null")
            result.success(false)
            return
        }

        if (routeOverlays.isEmpty()) {
            Log.e(TAG, "❌ [Native] routeOverlays 为空")
            result.success(false)
            return
        }

        if (index < 0 || index >= routeOverlays.size) {
            Log.e(TAG, "❌ [Native] 路线索引无效: index=$index, size=${routeOverlays.size}")
            result.error("INVALID_INDEX", "路线索引无效: $index", null)
            return
        }

        // 更新所有路线样式
        for ((i, polyline) in routeOverlays.withIndex()) {
            try {
                val newColor = if (i == index) 0xFF1890FF.toInt() else 0xFF999999.toInt()
                val newWidth = if (i == index) 12f else 8f
                polyline.color = newColor
                polyline.width = newWidth
                Log.d(TAG, "🗺️ [Native] 路线 $i 样式更新: color=${Integer.toHexString(newColor)}, width=$newWidth")
            } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 更新路线 $i 样式失败: ${e.message}")
            }
        }

        selectedRouteIndex = index
        Log.d(TAG, "✅ [Native] 选中路线 $index 完成")
        result.success(true)
    }

    /**
     * 清除所有路线
     */
    private fun clearRoutes() {
        Log.d(TAG, "🗺️ [Native] clearRoutes: 开始清除 ${routeOverlays.size} 条路线")
        for (polyline in routeOverlays) {
            try {
                polyline.remove()
            } catch (e: Exception) {
                Log.e(TAG, "❌ [Native] 移除路线失败: ${e.message}")
            }
        }
        routeOverlays.clear()
        selectedRouteIndex = -1
        // 同时清除路线标记
        clearRouteMarkers()
        Log.d(TAG, "🗑️ [Native] 已清除所有路线, routeOverlays.size=${routeOverlays.size}")
    }

    /**
     * 设置路线起点/终点标记
     */
    private fun setRouteMarkers(
        startLat: Double?,
        startLng: Double?,
        endLat: Double?,
        endLng: Double?,
        startLabel: String,
        endLabel: String,
        result: Result
    ) {
        if (aMap == null) {
            Log.e(TAG, "❌ [Native] 地图未初始化!")
            result.success(false)
            return
        }

        if (startLat == null || startLng == null || endLat == null || endLng == null) {
            Log.e(TAG, "❌ [Native] 坐标参数不能为空")
            result.success(false)
            return
        }

        try {
            // 清除旧标记
            clearRouteMarkers()

            val startPoint = com.amap.api.maps.model.LatLng(startLat, startLng)
            val endPoint = com.amap.api.maps.model.LatLng(endLat, endLng)

            // 添加起点标记（绿色）
            startMarker = aMap!!.addMarker(
                com.amap.api.maps.model.MarkerOptions()
                    .position(startPoint)
                    .title(startLabel)
                    .snippet("")
                    .icon(com.amap.api.maps.model.BitmapDescriptorFactory.defaultMarker(com.amap.api.maps.model.BitmapDescriptorFactory.HUE_GREEN))
            )

            // 添加终点标记（红色）
            endMarker = aMap!!.addMarker(
                com.amap.api.maps.model.MarkerOptions()
                    .position(endPoint)
                    .title(endLabel)
                    .snippet("")
                    .icon(com.amap.api.maps.model.BitmapDescriptorFactory.defaultMarker(com.amap.api.maps.model.BitmapDescriptorFactory.HUE_RED))
            )

            Log.d(TAG, "✅ [Native] 已添加起点标记: $startLabel ($startLat, $startLng)")
            Log.d(TAG, "✅ [Native] 已添加终点标记: $endLabel ($endLat, $endLng)")

            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "❌ [Native] 设置路线标记失败: ${e.message}")
            result.success(false)
        }
    }

    /**
     * 清除路线标记（起点/终点）
     */
    private fun clearRouteMarkers() {
        try {
            startMarker?.let {
                it.remove()
                startMarker = null
                Log.d(TAG, "🗑️ [Native] 已清除起点标记")
            }
            endMarker?.let {
                it.remove()
                endMarker = null
                Log.d(TAG, "🗑️ [Native] 已清除终点标记")
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ [Native] 清除路线标记失败: ${e.message}")
        }
    }

    private fun stopLocation() {
        locationClient?.stopLocation()
        locationListener = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopLocation()
        Log.d(TAG, "🔌 地图插件已分离")
    }
}
