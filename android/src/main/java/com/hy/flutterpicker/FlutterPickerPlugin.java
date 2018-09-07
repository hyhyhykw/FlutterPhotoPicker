package com.hy.flutterpicker;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.ArrayMap;
import android.util.DisplayMetrics;
import android.view.WindowManager;
import android.view.animation.LinearInterpolator;
import android.widget.Toast;

import com.google.gson.Gson;

import org.json.JSONException;
import org.json.JSONObject;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StringCodec;

/**
 * FlutterPickerPlugin
 */
public class FlutterPickerPlugin implements MethodCallHandler, PickerConstants, BinaryMessenger {
    private final PluginRegistry.Registrar registrar;
    private final FlutterPicker delegate;
    private final BasicMessageChannel<String> basicChannel;
    private final BasicMessageChannel<String> keysChannel;
    private final BasicMessageChannel<String> itemsChannel;
    private final FlutterActivity activity;

    private FlutterPickerPlugin(Registrar registrar, FlutterPicker delegate) {
        this.registrar = registrar;
        this.delegate = delegate;
        activity = (FlutterActivity) registrar.activity();
        basicChannel = new BasicMessageChannel<>(this, "flutter_picker/picker_items", StringCodec.INSTANCE);
        keysChannel = new BasicMessageChannel<>(this, "flutter_picker/picker_keys", StringCodec.INSTANCE);
        itemsChannel = new BasicMessageChannel<>(this, "flutter_picker/picker_cate_items", StringCodec.INSTANCE);
    }

    //宽度dp值
    private static int screenWidth;
    //高度dp值
    private static int screenHeight;
    private static double density;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);

        FlutterPicker picker = new FlutterPicker(registrar.activity());
        registrar.addActivityResultListener(picker);
        registrar.addRequestPermissionsResultListener(picker);
        DisplayMetrics displayMetrics = registrar.activity().getResources().getDisplayMetrics();

        int widthPixels = displayMetrics.widthPixels;
        screenWidth = SizeUtils.px2dp(registrar.context(), widthPixels);
        int heightPixels = displayMetrics.heightPixels;
        screenHeight = SizeUtils.px2dp(registrar.context(), heightPixels);
        density = registrar.context().getResources().getDisplayMetrics().density;
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
//            registrar.activity().getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
//        }
        FlutterPickerPlugin handler = new FlutterPickerPlugin(registrar, picker);

        channel.setMethodCallHandler(handler);
    }


    private static final String CHANNEL = "plugins.flutter.io/photo_picker";

    private ArrayMap<String, BeanWrapper> mItemMap = new ArrayMap<>();
    private BeanWrapper mWrapper;

    @Override
    public void onMethodCall(MethodCall call, final MethodChannel.Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case OPEN_CAMERA:
                delegate.openCamera();
                break;
            case OPEN_GALLERY:
                boolean gif = true;
                Object arguments = call.arguments;
                if (arguments instanceof Boolean) {
                    gif = (boolean) arguments;
                }
                delegate.openGallery(gif, new FlutterPicker.GalleryListener() {
                    @Override
                    public void onGallery(BeanWrapper wrapper, ArrayList<CateLogItem> catelog, ArrayMap<String, BeanWrapper> map) {
                        mWrapper = wrapper;
                        mItemMap.clear();
                        mItemMap.putAll(map);
                        Map<String, Object> cateMap = new HashMap<>();
                        cateMap.put("catelog", catelog);
                        keysChannel.send(new Gson().toJson(cateMap));
                        basicChannel.send(new Gson().toJson(wrapper));
                    }

                    @Override
                    public void onFailed(String errorCode, String errorMessage) {
                        result.error(errorCode, errorMessage, null);
                    }
                });
                break;
            case TOAST:
                Object message = call.arguments;
                if (message instanceof CharSequence) {
                    Toast.makeText(registrar.context(), (CharSequence) message, Toast.LENGTH_SHORT).show();
                }
                break;
            case SCREEN_HEIGHT:
                result.success(screenHeight);
                break;
            case SCREEN_WIDTH:
                result.success(screenWidth);
                break;
            case GET_DENSITY:
                result.success(density);
                break;
            case SWITCH_FULL_SCREEN:
                Object isFull = call.arguments;
                boolean fullScreen = true;
                if (isFull instanceof Boolean) {
                    fullScreen = (boolean) isFull;
                }
                switchFullScreen(fullScreen);
                break;
            case GET_ITEMS: {
                Object key = call.arguments;
                String cateLog = "";
                if (key instanceof String) {
                    cateLog = (String) key;
                }
                if (cateLog.isEmpty()) {
                    itemsChannel.send(new Gson().toJson(mWrapper));
                } else {
                    BeanWrapper wrapper = mItemMap.get(cateLog);
                    itemsChannel.send(new Gson().toJson(wrapper));
                }
            }
            break;

            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * 设置全屏
     */
    private void setFullScreen() {
        activity.getWindow().setFlags(
                WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
    }

    /**
     * 取消全屏
     */
    private void cancelFullScreen() {
        activity.getWindow().clearFlags(
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
    }

    private void switchFullScreen(boolean fullScreen) {
        if (fullScreen) {
            setFullScreen();
        } else {
            cancelFullScreen();
        }
    }

    @Override
    public void send(String channel, ByteBuffer byteBuffer) {
        activity.getFlutterView().send(channel, byteBuffer);
    }

    @Override
    public void send(String channel, ByteBuffer message, BinaryReply callback) {
        activity.getFlutterView().send(channel, message, callback);
    }

    @Override
    public void setMessageHandler(String channel, BinaryMessageHandler handler) {
        activity.getFlutterView().setMessageHandler(channel, handler);
    }
}
