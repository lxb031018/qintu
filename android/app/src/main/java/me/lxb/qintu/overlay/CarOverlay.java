package me.lxb.qintu.overlay;

import android.content.Context;
import android.graphics.BitmapFactory;
import android.util.Log;

import com.amap.api.maps.AMap;
import com.amap.api.maps.model.BitmapDescriptor;
import com.amap.api.maps.model.BitmapDescriptorFactory;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.Marker;
import com.amap.api.maps.model.MarkerOptions;
import me.lxb.qintu.R;

/**
 * 自车位置管理Overlay类
 * 参考官方 CarOverlay.java，简化版本
 */
public class CarOverlay {
    private static final String TAG = "CarOverlay";

    private BitmapDescriptor carDescriptor = null;
    private BitmapDescriptor directionDescriptor = null;
    private Marker carMarker = null;
    private Marker directionMarker = null;
    private boolean isDirectionVisible = true;

    public CarOverlay(Context context) {
        // 加载车辆图标
        carDescriptor = BitmapDescriptorFactory.fromBitmap(
            BitmapFactory.decodeResource(context.getResources(), R.drawable.caricon)
        );
        // 加载方向指示图标
        directionDescriptor = BitmapDescriptorFactory.fromBitmap(
            BitmapFactory.decodeResource(context.getResources(), R.drawable.navi_direction)
        );
        Log.d(TAG, "CarOverlay 初始化完成");
    }

    /**
     * 绘制自车位置
     * @param aMap AMap实例
     * @param latLng 当前位置坐标
     * @param bearing 行进方向角度
     */
    public void draw(AMap aMap, LatLng latLng, float bearing) {
        if (aMap == null || latLng == null || carDescriptor == null) {
            Log.w(TAG, "draw: aMap或latLng为空，跳过绘制");
            return;
        }

        try {
            // 创建或更新车辆标记
            if (carMarker == null) {
                carMarker = aMap.addMarker(new MarkerOptions()
                    .anchor(0.5f, 0.5f)  // 中心对齐
                    .setFlat(true)       // 贴地显示
                    .icon(carDescriptor)
                    .position(latLng));
            }

            // 创建或更新方向标记
            if (directionMarker == null) {
                directionMarker = aMap.addMarker(new MarkerOptions()
                    .anchor(0.5f, 0.5f)
                    .setFlat(true)
                    .icon(directionDescriptor)
                    .position(latLng));
                directionMarker.setVisible(isDirectionVisible);
            }

            // 更新位置和角度
            carMarker.setPosition(latLng);
            carMarker.setRotateAngle(360 - bearing);  // AMap使用反向角度
            carMarker.setFlat(true);
            carMarker.setVisible(true);

            // 更新方向标记
            if (directionMarker != null) {
                directionMarker.setPosition(latLng);
                directionMarker.setRotateAngle(360 - bearing);
                directionMarker.setVisible(isDirectionVisible);
            }

            Log.v(TAG, String.format("📍 自车位置更新: (%.6f, %.6f), 方向: %.1f°",
                latLng.latitude, latLng.longitude, bearing));

        } catch (Throwable e) {
            Log.e(TAG, "绘制自车失败: " + e.getMessage());
        }
    }

    /**
     * 设置方向指示器可见性
     */
    public void setDirectionVisible(boolean visible) {
        this.isDirectionVisible = visible;
        if (directionMarker != null) {
            directionMarker.setVisible(visible);
        }
    }

    /**
     * 释放资源
     */
    public void destroy() {
        if (carMarker != null) {
            carMarker.remove();
            carMarker = null;
        }
        if (directionMarker != null) {
            directionMarker.remove();
            directionMarker = null;
        }
        carDescriptor = null;
        directionDescriptor = null;
        Log.d(TAG, "CarOverlay 资源已释放");
    }
}
