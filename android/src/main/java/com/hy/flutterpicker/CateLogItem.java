package com.hy.flutterpicker;

/**
 * Created time : 2018/9/5 17:51.
 *
 * @author HY
 */
public class CateLogItem {
    private String key;
    private String image;
    private int number;

    public CateLogItem() {
    }

    public CateLogItem(String key, String image) {
        this.key = key;
        this.image = image;
    }

    public CateLogItem(String key, String image, int number) {
        this.key = key;
        this.image = image;
        this.number = number;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }
}
