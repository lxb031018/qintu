package me.lxb.qintu.util

import android.content.Context
import com.amap.api.maps.MapsInitializer
import com.amap.api.services.core.ServiceSettings

object AMapPrivacy {
    fun initMap(context: Context) {
        MapsInitializer.updatePrivacyShow(context, true, true)
        MapsInitializer.updatePrivacyAgree(context, true)
    }

    fun initSearch(context: Context) {
        ServiceSettings.updatePrivacyShow(context, true, true)
        ServiceSettings.updatePrivacyAgree(context, true)
    }
}
