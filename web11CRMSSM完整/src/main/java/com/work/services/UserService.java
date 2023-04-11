package com.work.services;

import com.work.beans.User;

import java.util.List;


public interface UserService extends BaseServices<User,String> {

   User login(String username, String  password);

   List<String> getAllUserNameJSON();
}
