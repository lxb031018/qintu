package me.lxb.qintu.background

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.util.Log
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener

/**
 * 后台定位前台服务
 *
 * 创建独立的 AMapLocationClient 实例（10s 间隔），通过前台通知维持进程优先级。
 * Plugin 通过 [bindService] 获取 [LocationCallback] 以接收定位回调。
 */
class BackgroundLocationService : Service() {

    companion object {
        private const val TAG = "BgLocationService"
        const val CHANNEL_ID = "qintu_background_location"
        const val NOTIFICATION_ID = 1001
    }

    private var locationClient: AMapLocationClient? = null
    private var callback: LocationCallback? = null
    private val binder = LocalBinder()

    interface LocationCallback {
        fun onLocationResult(location: AMapLocation)
        fun onError(errorCode: Int, errorInfo: String)
    }

    inner class LocalBinder : Binder() {
        fun getService(): BackgroundLocationService = this@BackgroundLocationService
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        initLocationClient()
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, buildNotification())
        locationClient?.startLocation()
        Log.d(TAG, "后台定位服务已启动")
        return START_STICKY
    }

    override fun onDestroy() {
        locationClient?.stopLocation()
        locationClient?.onDestroy()
        locationClient = null
        callback = null
        Log.d(TAG, "后台定位服务已销毁")
        super.onDestroy()
    }

    fun registerCallback(cb: LocationCallback) {
        callback = cb
    }

    fun unregisterCallback() {
        callback = null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "后台定位",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "位置共享运行中"
                setShowBadge(false)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this, 0, packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("Qintu")
                .setContentText("位置共享运行中")
                .setSmallIcon(android.R.drawable.ic_menu_mylocation)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("Qintu")
                .setContentText("位置共享运行中")
                .setSmallIcon(android.R.drawable.ic_menu_mylocation)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        }
    }

    private fun initLocationClient() {
        try {
            locationClient = AMapLocationClient(applicationContext)
            val option = AMapLocationClientOption().apply {
                locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
                interval = 10000
                isOnceLocation = false
                isSensorEnable = false
                isNeedAddress = true
                isLocationCacheEnable = false
            }
            locationClient?.setLocationOption(option)
            locationClient?.setLocationListener { location ->
                onLocationChanged(location)
            }
            Log.d(TAG, "后台定位客户端初始化完成")
        } catch (e: Exception) {
            Log.e(TAG, "后台定位客户端初始化失败", e)
        }
    }

    private fun onLocationChanged(location: AMapLocation?) {
        if (location == null) return
        if (location.errorCode == 0) {
            callback?.onLocationResult(location)
        } else {
            Log.e(TAG, "后台定位失败: ${location.errorCode} - ${location.errorInfo}")
            callback?.onError(location.errorCode, location.errorInfo ?: "未知错误")
        }
    }
}
