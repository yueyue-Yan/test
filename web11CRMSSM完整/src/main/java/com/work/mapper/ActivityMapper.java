package com.work.mapper;

import com.work.beans.Activity;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface ActivityMapper extends BaseMapper<Activity,String> {
    //分页参数：@Param("startIndex") int startIndex,@Param("rowsPerPage") int rowsPerPage
    //查询参数:Map searchMap
    //问题1：为什么不直接用参数Page page代替这三个参数？

    //如果方法重载（OverRide），则不支持default
    List<Activity> getAll(@Param("startIndex") int startIndex, @Param("rowsPerPage") int rowsPerPage, @Param("searchMap") Map searchMap);

    int getCount(@Param("searchMap") Map searchMap);

    Activity getRemarks(@Param("id") String id);


    //问题2： 为什么同是实体类，activity可以作为参数，而page类不行？
    //@Override
    //int save(Activity activity);

}


//答1：
// 1. 实体类page中参数众多，还有个返回结果集List data，其他的数据库不一定适合
// 2.page中参数多，用的少
// 3. page做参数，使得该项目必须依赖page类，耦合度高，依赖性太强

//答2：
//因为只有ORM beans即表格beans才能出现在mapper的方法中做参数，功能beans不可以
