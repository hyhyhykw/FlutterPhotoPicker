package com.hy.flutterpicker;

import android.Manifest;

/**
 * Created time : 2018/8/31 9:57.
 *
 * @author HY
 */
public interface PickerConstants {
    String[] CAMERA = {
            Manifest.permission.CAMERA,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    };
    String[] STORAGE = {
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    };
    int REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION = 0x01;
    int REQUEST_CAMERA_PERMISSION = 0x02;
    int REQUEST_CAMERA = 0x03;
    String OPEN_CAMERA = "openCamera";
    String OPEN_GALLERY = "openGallery";
    String TOAST = "toast";
    String SCREEN_HEIGHT = "getScreenHeight";
    String SCREEN_WIDTH = "getScreenWidth";
    String SWITCH_FULL_SCREEN = "switchFullScreen";
    String GET_ITEMS = "getItems";
    String GET_DENSITY = "getDensity";

}
