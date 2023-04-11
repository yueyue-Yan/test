package com.work.mapper;

import com.work.beans.User;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface UserMapper extends BaseMapper<User,String> {

    User get(@Param("username") String username, @Param("password") String password);

    //List<String> getAllUserNameJSON();
    List<String> getAllJSON();

}

