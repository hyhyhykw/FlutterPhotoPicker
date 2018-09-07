package com.hy.flutterpicker;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.database.Cursor;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.FileProvider;
import android.util.ArrayMap;
import android.widget.Toast;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * Created time : 2018/8/31 9:29.
 *
 * @author HY
 */
public class FlutterPicker implements PluginRegistry.ActivityResultListener,
        PluginRegistry.RequestPermissionsResultListener, PickerConstants {
    private Activity activity;


    public FlutterPicker(Activity activity) {
        this.activity = activity;
    }

    public boolean isPermissionGranted(String permissionName) {
        return ActivityCompat.checkSelfPermission(activity, permissionName)
                == PackageManager.PERMISSION_GRANTED;
    }

    public boolean isPermissionGranted(String[] permissions) {
        boolean isPermissionGranted = true;
        for (String permission : permissions) {
            isPermissionGranted = isPermissionGranted && isPermissionGranted(permission);
        }
        return isPermissionGranted;
    }

    public void askForPermission(String[] permissions, int requestCode) {
        ActivityCompat.requestPermissions(activity, permissions, requestCode);
    }

    public void openCamera() {

        ArrayList<String> permissions = new ArrayList<>();
        for (String s : CAMERA) {
            if (!isPermissionGranted(s)) {
                permissions.add(s);
            }
        }
        if (permissions.isEmpty()) {
            requestCamera();
        } else {
            askForPermission(permissions.toArray(new String[permissions.size()]), REQUEST_CAMERA_PERMISSION);
        }
    }


    private void finishWithError(String errorCode, String errorMessage) {

    }


    private Uri mTakePictureUri;

    protected void requestCamera() {
        if (!CommonUtils.existSDCard()) {
            finishWithError("no_available_disk", "No sd card available.");
            return;
        }

        File path = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);
        if (!path.exists()) {
            boolean mkdirs = path.mkdirs();
            Logger.d("文件夹：" + path + "创建" + (mkdirs ? "成功" : "失败"));
        }

        String name = "IMG-" + CommonUtils.format(new Date(), "yyyy-MM-dd-HHmmss") + ".jpg";
        File file = new File(path, name);
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        List<ResolveInfo> resInfoList = activity.getPackageManager().queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);
        if (resInfoList.size() <= 0) {
            finishWithError("no_available_camera", "No cameras available for taking pictures.");
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                mTakePictureUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".file_provider", file);
                intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            } else {
                mTakePictureUri = Uri.fromFile(file);
            }

            intent.putExtra(MediaStore.EXTRA_OUTPUT, mTakePictureUri);
            activity.startActivityForResult(intent, REQUEST_CAMERA);
        }
    }

    private String mPath;

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (mTakePictureUri != null) {
            String path = mTakePictureUri.getEncodedPath();// getPathFromUri(this, mTakePhotoUri);

            if (mTakePictureUri.toString().startsWith("content")) {
                path = path.replaceAll("/external_storage_root", "");

                path = Environment.getExternalStorageDirectory() + path;
            }

            File file = new File(path);
            if (file.exists()) {
                PicItem item = new PicItem();
                item.uri = path;
                item.selected = true;

                MediaScannerConnection.scanFile(activity, new String[]{path}, null, new MediaScannerConnection.OnScanCompletedListener() {
                    @Override
                    public void onScanCompleted(final String path, Uri uri) {
                        Logger.d("path===" + path);
                        mPath = path;
                        openGallery();
                    }
                });

                //sTakePhotoListener.onTake(item);
                // finish();
            } else {
                //Toast.makeText(this, R.string.picker_photo_failure, Toast.LENGTH_SHORT).show();
                //finish();
            }
        } else {
            // Toast.makeText(this, R.string.picker_photo_failure, Toast.LENGTH_SHORT).show();
            //finish();
        }
        return false;
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] strings, int[] ints) {
        if (isPermissionGranted(strings)) {
            if (requestCode == REQUEST_CAMERA_PERMISSION) {
                requestCamera();
            } else if (requestCode == REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION) {
                openGallery();
            }
        } else {
            if (requestCode == REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION) {
                mGalleryListener.onFailed("permission_denial", "Permission Denial");
            } else {
                finishWithError("permission_denial", "Permission Denial");
            }
        }

        return false;
    }

    private GalleryListener mGalleryListener;

    public interface GalleryListener {
        void onGallery(BeanWrapper picItems, ArrayList<CateLogItem> catelog, ArrayMap<String, BeanWrapper> map);

        void onFailed(String errorCode, String errorMessage);
    }

    private boolean gif;

    public void openGallery(boolean gif, GalleryListener galleryListener) {
        this.gif = gif;
        mGalleryListener = galleryListener;

        ArrayList<String> permissions = new ArrayList<>();
        for (String s : STORAGE) {
            if (!isPermissionGranted(s)) {
                permissions.add(s);
            }
        }
        if (permissions.isEmpty()) {
            openGallery();
        } else {
            askForPermission(permissions.toArray(new String[permissions.size()]), REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION);
        }
    }

    private boolean isGif(PicItem item) {
        return item.uri.toLowerCase(Locale.getDefault()).endsWith("gif");
    }

    private void openGallery() {
        String[] projection = new String[]{"_data", "date_added"};
        String orderBy = "datetaken DESC";
        Cursor cursor = activity.getContentResolver().query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, projection, null, null, orderBy);
        List<PicItem> mAllItemList = new ArrayList<>();
        ArrayList<CateLogItem> mCatalogList = new ArrayList<>();
        ArrayMap<String, BeanWrapper> mItemMap = new ArrayMap<>();
        if (cursor != null) {
            if (cursor.moveToFirst()) {
                do {
                    PicItem item = new PicItem();
                    item.uri = cursor.getString(0);
                    if (item.uri == null) {
                        continue;
                    }

                    if (!gif && isGif(item)) {
                        continue;
                    }
                    if (item.uri.equals(mPath)) {
                        item.selected = true;
                        mPath = "";
                    }

                    File file = new File(item.uri);

                    if (!file.exists() || file.length() == 0L) {
                        continue;
                    }

//                    if (null != mSelectItems && !mSelectItems.isEmpty()) {
//                        boolean remove = mSelectItems.remove(item);
//                        item.setSelected(remove);
//                    }
                    mAllItemList.add(item);
                    int last = item.uri.lastIndexOf("/");
                    if (last != -1) {
                        String catalog;
                        if (last == 0) {
                            catalog = "/";
                        } else {
                            int secondLast = item.uri.lastIndexOf("/", last - 1);
                            catalog = item.uri.substring(secondLast + 1, last);
                        }

                        if (mItemMap.containsKey(catalog)) {
                            mItemMap.get(catalog).getItems().add(item);
                        } else {
                            List<PicItem> itemList = new ArrayList<>();
                            itemList.add(item);
                            mItemMap.put(catalog, new BeanWrapper(itemList));
                            mCatalogList.add(new CateLogItem(catalog, item.uri));
                        }
                    }
                } while (cursor.moveToNext());
            }

            cursor.close();
        }
        BeanWrapper beanWrapper = new BeanWrapper(mAllItemList);
        mCatalogList.add(0, new CateLogItem("", beanWrapper.getItems().get(0).uri, beanWrapper.getItems().size()));

        for (CateLogItem cateLogItem : mCatalogList) {
            String key = cateLogItem.getKey();
            if (key.isEmpty())
                continue;
            cateLogItem.setNumber(mItemMap.get(key).getItems().size());
        }
        mGalleryListener.onGallery(beanWrapper, mCatalogList, mItemMap);
    }
}
