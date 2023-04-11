package com.work.services;

import com.work.beans.ActRemark;
import com.work.beans.Activity;
import com.work.beans.Page;

import java.util.List;

public interface ActivityService extends BaseServices<Activity, String> {
    //问题1：业务层为什么不是三个参数而是一整个page做参数呢？
    //答1：业务层是针对需求的，根据需要的功能进行设计，也可以帮控制层分担压力（计算，判断...）
    // Page getAll(Page page);

    Activity getRemarks(String id);

    int deleteRemarks(String id);

    int saveRemark(ActRemark actRemark);
}
