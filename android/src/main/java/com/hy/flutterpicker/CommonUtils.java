package com.hy.flutterpicker;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;

import java.lang.reflect.Field;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created time : 2018/4/3 11:42.
 *
 * @author HY
 */
@SuppressWarnings("unchecked")
public class CommonUtils {
    /**
     * 判断SDCard是否可用
     */
    public static boolean existSDCard() {
        return Environment.getExternalStorageState().equals(
                Environment.MEDIA_MOUNTED);
    }


    /**
     * 获取状态栏高度
     *
     * @return 通知栏高度
     */
    public static int getStatusBarHeight( Context context) {
        int statusBarHeight = 0;
        if (null == context) return 0;
        try {
            @SuppressLint("PrivateApi")
            Class clazz = Class.forName("com.android.internal.R$dimen");
            Object obj = clazz.newInstance();
            Field field = clazz.getField("status_bar_height");
            int temp = Integer.parseInt(field.get(obj).toString());
            statusBarHeight = context.getResources().getDimensionPixelSize(temp);
        } catch (Exception e) {
            Logger.e("Exception", e);
        }

        return statusBarHeight;
    }

    /**
     * 功能描述：格式化输出日期
     *
     * @param date   Date 日期
     * @param format String 格式
     * @return 返回字符型日期
     */
    public static String format(Date date, String format) {
        String result = "";
        try {
            if (date != null) {
                SimpleDateFormat sdf = (SimpleDateFormat) SimpleDateFormat.getInstance();
                sdf.applyPattern(format);
                result = sdf.format(date);
            }
        } catch (Exception ignored) {
        }
        return result;
    }

    /**
     * 获取手机厂商
     *
     * @return 手机厂商
     */
    public static String getDeviceBrand() {
        return Build.BRAND;
    }


    private static final Handler MAIN_HANDLER = new Handler(Looper.getMainLooper());

    public static void postDelay(Runnable action, long delay) {
        MAIN_HANDLER.postDelayed(action, delay);
    }

    public static void post(Runnable action) {
        postDelay(action, 0);
    }
}
