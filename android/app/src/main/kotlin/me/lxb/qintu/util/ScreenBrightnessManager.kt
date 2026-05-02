package me.lxb.qintu.util

import android.app.Activity
import android.util.Log
import android.view.WindowManager

object ScreenBrightnessManager {

    private const val TAG = "ScreenBrightness"
    private const val KEEP_SCREEN_ON = WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON

    fun activate(activity: Activity) {
        val beforeFlags = activity.window.attributes.flags
        Log.d(TAG, "📍 activate 前的 flags: $beforeFlags, KEEP_SCREEN_ON=${beforeFlags and KEEP_SCREEN_ON != 0}")
        activity.window.setFlags(KEEP_SCREEN_ON, KEEP_SCREEN_ON)
        val afterFlags = activity.window.attributes.flags
        Log.d(TAG, "✅ Activity 屏幕常亮已激活, 后的 flags: $afterFlags, KEEP_SCREEN_ON=${afterFlags and KEEP_SCREEN_ON != 0}")
    }

    fun deactivate(activity: Activity) {
        val beforeFlags = activity.window.attributes.flags
        Log.d(TAG, "📍 deactivate 前的 flags: $beforeFlags, KEEP_SCREEN_ON=${beforeFlags and KEEP_SCREEN_ON != 0}")
        activity.window.setFlags(0, KEEP_SCREEN_ON)
        val afterFlags = activity.window.attributes.flags
        Log.d(TAG, "✅ Activity 屏幕常亮已关闭, 后的 flags: $afterFlags, KEEP_SCREEN_ON=${afterFlags and KEEP_SCREEN_ON != 0}")
    }
}