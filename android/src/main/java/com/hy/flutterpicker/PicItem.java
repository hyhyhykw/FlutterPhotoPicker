package com.hy.flutterpicker;

/**
 * Created time : 2018/8/30 17:57.
 *
 * @author HY
 */
public class PicItem {
    public String uri;
    public boolean selected;

    public PicItem() {
    }

    public PicItem(String uri, boolean selected) {
        this.uri = uri;
        this.selected = selected;
    }


    public String getUri() {
        return uri;
    }

    public void setUri(String uri) {
        this.uri = uri;
    }

    public boolean isSelected() {
        return selected;
    }

    public void setSelected(boolean selected) {
        this.selected = selected;
    }

}
