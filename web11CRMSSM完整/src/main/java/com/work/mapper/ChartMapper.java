package com.work.mapper;

import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ChartMapper {
    List activityChart(@Param("year") int year,@Param("months") List months);
}
