package com.work.services;

import com.work.beans.Page;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface BaseServices<T, I> {
    //适配设计模式
    default T get(@Param("id") I id) {
        return null;
    }

    default List<T> getAll() {
        return null;
    }

    default Page getAll(Page page) {
        return null;
    }

    default int save(T t) {
        return 0;
    }

    default int edit(T t) {
        return 0;
    }

    default int delete(I[] ids) {
        return 0;
    }




}
