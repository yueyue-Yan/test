package com.work.mapper;

import com.work.beans.ActRemark;

import java.util.List;

public interface ActRemarkMapper {

    //通过ActRemark表的外键查找
    List<ActRemark> getAllByMarketingActivitiesId(String marketingActivitiesId);

    int deleteRemarks(String id);

    int saveRemark(ActRemark actRemark);
    int editRemark(ActRemark actRemark);
}
