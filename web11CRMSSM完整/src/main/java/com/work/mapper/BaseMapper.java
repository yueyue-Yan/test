package com.work.mapper;

import org.apache.ibatis.annotations.Param;

import java.util.List;
//import java.util.Map;

public interface BaseMapper<T, I> {

    T get(@Param("id") I id);
    List<T> getAll();
    int save(T t);
    int edit(T t);
    int delete(I[] ids);


}
