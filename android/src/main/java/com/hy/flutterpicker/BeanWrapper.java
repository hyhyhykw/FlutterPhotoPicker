package com.hy.flutterpicker;

import java.util.List;

/**
 * Created time : 2018/8/31 17:12.
 *
 * @author HY
 */
public class BeanWrapper {
    private List<PicItem> items;

    public BeanWrapper(List<PicItem> items) {
        this.items = items;
    }

    public BeanWrapper() {
    }

    public List<PicItem> getItems() {
        return items;
    }

    public void setItems(List<PicItem> items) {
        this.items = items;
    }
}
