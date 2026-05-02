package me.lxb.qintu.util

import android.app.Activity
import android.view.WindowManager

object ScreenBrightnessManager {

    private const val KEEP_SCREEN_ON = WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON

    fun activate(activity: Activity) {
        activity.window.addFlags(KEEP_SCREEN_ON)
    }

    fun deactivate(activity: Activity) {
        activity.window.clearFlags(KEEP_SCREEN_ON)
    }
}
