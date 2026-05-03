package me.lxb.qintu.route

import android.content.Context
import android.util.Log
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.route.RouteSearch
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import me.lxb.qintu.constant.PlatformChannels

class RouteSearchPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        private const val TAG = "RouteSearch"
    }

    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var routeSearchImpl: RouteSearchImpl? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, PlatformChannels.ROUTE_SEARCH)
        channel.setMethodCallHandler(this)

        Log.d(TAG, "路径搜索插件已注册")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val impl = routeSearchImpl
        if (impl == null) {
            result.error("NOT_READY", "路径搜索模块未初始化，请确保 Activity 已绑定", null)
            return
        }

        when (call.method) {
            "calculateDriveRoute" -> {
                val fromLat = call.argument<Double>("fromLat") ?: return result.error("INVALID_PARAMS", "fromLat 缺失", null)
                val fromLng = call.argument<Double>("fromLng") ?: return result.error("INVALID_PARAMS", "fromLng 缺失", null)
                val toLat = call.argument<Double>("toLat") ?: return result.error("INVALID_PARAMS", "toLat 缺失", null)
                val toLng = call.argument<Double>("toLng") ?: return result.error("INVALID_PARAMS", "toLng 缺失", null)
                val strategy = call.argument<Int>("strategy") ?: 0
                val alternativeRoute = call.argument<Int>("alternativeRoute") ?: 1
                val carType = call.argument<Int>("carType") ?: 0
                val passedPoints = call.argument<List<Map<String, Double>>>("passedPoints")?.map {
                    LatLonPoint(it["lat"]!!, it["lng"]!!)
                }

                impl.calculateDriveRoute(fromLat, fromLng, toLat, toLng, strategy, { res, err ->
                    if (err != null) {
                        result.error("CALC_ERROR", err, null)
                    } else {
                        result.success(res)
                    }
                }, alternativeRoute, carType, passedPoints)
            }

            "calculateWalkRoute" -> {
                val fromLat = call.argument<Double>("fromLat") ?: return result.error("INVALID_PARAMS", "fromLat 缺失", null)
                val fromLng = call.argument<Double>("fromLng") ?: return result.error("INVALID_PARAMS", "fromLng 缺失", null)
                val toLat = call.argument<Double>("toLat") ?: return result.error("INVALID_PARAMS", "toLat 缺失", null)
                val toLng = call.argument<Double>("toLng") ?: return result.error("INVALID_PARAMS", "toLng 缺失", null)
                val alternativeRoute = call.argument<Int>("alternativeRoute") ?: 1

                impl.calculateWalkRoute(fromLat, fromLng, toLat, toLng, { res, err ->
                    if (err != null) {
                        result.error("CALC_ERROR", err, null)
                    } else {
                        result.success(res)
                    }
                }, alternativeRoute)
            }

            "calculateRideRoute" -> {
                val fromLat = call.argument<Double>("fromLat") ?: return result.error("INVALID_PARAMS", "fromLat 缺失", null)
                val fromLng = call.argument<Double>("fromLng") ?: return result.error("INVALID_PARAMS", "fromLng 缺失", null)
                val toLat = call.argument<Double>("toLat") ?: return result.error("INVALID_PARAMS", "toLat 缺失", null)
                val toLng = call.argument<Double>("toLng") ?: return result.error("INVALID_PARAMS", "toLng 缺失", null)
                val alternativeRoute = call.argument<Int>("alternativeRoute") ?: 1

                impl.calculateRideRoute(fromLat, fromLng, toLat, toLng, { res, err ->
                    if (err != null) {
                        result.error("CALC_ERROR", err, null)
                    } else {
                        result.success(res)
                    }
                }, alternativeRoute)
            }

            "calculateBusRoute" -> {
                val fromLat = call.argument<Double>("fromLat") ?: return result.error("INVALID_PARAMS", "fromLat 缺失", null)
                val fromLng = call.argument<Double>("fromLng") ?: return result.error("INVALID_PARAMS", "fromLng 缺失", null)
                val toLat = call.argument<Double>("toLat") ?: return result.error("INVALID_PARAMS", "toLat 缺失", null)
                val toLng = call.argument<Double>("toLng") ?: return result.error("INVALID_PARAMS", "toLng 缺失", null)
                val city = call.argument<String>("city") ?: ""
                val mode = call.argument<Int>("mode") ?: 0
                val maxTrans = call.argument<Int>("maxTrans") ?: 3
                val alternativeRoute = call.argument<Int>("alternativeRoute") ?: 1
                val time = call.argument<String>("time")
                val timeType = call.argument<String>("timeType")
                val destCity = call.argument<String>("destCity")

                impl.calculateBusRoute(fromLat, fromLng, toLat, toLng, city, mode, { res, err ->
                    if (err != null) {
                        result.error("CALC_ERROR", err, null)
                    } else {
                        result.success(res)
                    }
                }, maxTrans, alternativeRoute, time, timeType, destCity)
            }

            "calculateTruckRoute" -> {
                val fromLat = call.argument<Double>("fromLat") ?: return result.error("INVALID_PARAMS", "fromLat 缺失", null)
                val fromLng = call.argument<Double>("fromLng") ?: return result.error("INVALID_PARAMS", "fromLng 缺失", null)
                val toLat = call.argument<Double>("toLat") ?: return result.error("INVALID_PARAMS", "toLat 缺失", null)
                val toLng = call.argument<Double>("toLng") ?: return result.error("INVALID_PARAMS", "toLng 缺失", null)
                val strategy = call.argument<Int>("strategy") ?: 0
                val truckSize = call.argument<Int>("truckSize") ?: RouteSearch.TRUCK_SIZE_LIGHT
                val truckHeight = call.argument<Double>("truckHeight")?.toFloat() ?: 1.6f
                val truckWidth = call.argument<Double>("truckWidth")?.toFloat() ?: 2.5f
                val truckLoad = call.argument<Double>("truckLength")?.toFloat() ?: 0.9f
                val truckWeight = call.argument<Double>("truckWeight")?.toFloat() ?: 10f
                val truckAxis = call.argument<Double>("truckAxis")?.toFloat() ?: 2f

                impl.calculateTruckRoute(fromLat, fromLng, toLat, toLng, strategy, { res, err ->
                    if (err != null) {
                        result.error("CALC_ERROR", err, null)
                    } else {
                        result.success(res)
                    }
                }, truckSize, truckHeight, truckWidth, truckLoad, truckWeight, truckAxis)
            }

            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        routeSearchImpl = RouteSearchImpl(binding.activity)
        Log.d(TAG, "已绑定 Activity，路径搜索模块初始化完成")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        routeSearchImpl?.destroy()
        routeSearchImpl = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        routeSearchImpl = RouteSearchImpl(binding.activity)
    }

    override fun onDetachedFromActivity() {
        routeSearchImpl?.destroy()
        routeSearchImpl = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        routeSearchImpl?.destroy()
        routeSearchImpl = null
        Log.d(TAG, "路径搜索插件已分离")
    }
}