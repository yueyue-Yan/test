package com.work.services;

import com.work.beans.ActRemark;
import com.work.beans.Activity;
import com.work.beans.Page;
import com.work.mapper.ActRemarkMapper;
import com.work.mapper.ActivityMapper;
import com.work.tools.UUIDUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class ActivityServiceImpl implements ActivityService {
    @Autowired
    ActivityMapper activityMapper;
    @Autowired
    ActRemarkMapper actRemarkMapper;

    @Override
    public Page getAll(Page page) {
        //当前页
        Integer currentPage = page.getCurrentPage();
        //每页显示行数
        Integer rowsPerPage = page.getRowsPerPage();
        ///limit需求的第一个参数
        int startIndex = (currentPage - 1) * rowsPerPage;

        //计算1：总记录数（需要Dao层(mapper.xml)的聚合查询(count(*))支持）
        int count = activityMapper.getCount(page.getSearchMap());
        page.setTotalPages(count);
        //计算2：总页数
        if (count % rowsPerPage == 0) {
            page.setTotalPages(count / rowsPerPage);
        } else {
            page.setTotalPages((count / rowsPerPage) + 1);
        }
        //需要有三個參數，
        List<Activity> all = activityMapper.getAll(startIndex, rowsPerPage, page.getSearchMap());

        //添加数据集
        page.setData(all);

        return page;
    }

    @Override
    public int delete(String[] ids) {
        return activityMapper.delete(ids);
    }

    @Override
    public int save(Activity activity) {
        //添加前端没有给出的数据id和CreateTime
        String id = UUIDUtils.getUUID();
        activity.setId(id);
        //获取当前时间
        LocalDateTime localDateTime = LocalDateTime.now();
        //格式化样式
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        //格式化当前时间
        String createTime = dateTimeFormatter.format(localDateTime);
        //set
        activity.setCreateTime(createTime);

        return activityMapper.save(activity);
    }
    @Override
    public Activity get(String id) {
        return activityMapper.get(id);
    }

    @Override
    public int edit(Activity activity) {
        LocalDateTime localDateTime=LocalDateTime.now();
        DateTimeFormatter dateTimeFormatter=DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        String editTime = dateTimeFormatter.format(localDateTime);
        activity.setEditTime(editTime);

        return activityMapper.edit(activity);
    }


    @Override
    public Activity getRemarks(String id) {
        return activityMapper.getRemarks(id);
    }

    @Override
    public int deleteRemarks(String id) {

        return actRemarkMapper.deleteRemarks(id);
    }

    @Override
    public int saveRemark(ActRemark actRemark) {
        int temp = 0;
        if (actRemark.getId() == null) {
            //添加:业务层负责id参数和时间参数，控制层负责添加人名称参数
            actRemark.setId(UUIDUtils.getUUID());
            actRemark.setNoteTime(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(LocalDateTime.now()));
            //执行添加mapper
            temp = actRemarkMapper.saveRemark(actRemark);
        }
        else {
            //修改：业务层负责flag参数和时间参数，控制层负责修改人名称参数
            actRemark.setEditTime(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(LocalDateTime.now()));
            actRemark.setEditFlag(1);
            //执行修改mapper
            temp = actRemarkMapper.editRemark(actRemark);
        }
        return temp;
    }
}

