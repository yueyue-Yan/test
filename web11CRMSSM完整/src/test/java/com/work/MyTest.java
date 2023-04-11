package com.work;

import com.work.beans.User;
import com.work.mapper.UserMapper;
import com.work.services.UserService;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import javax.servlet.http.HttpServletRequest;

//设置Spring测试启动类
@RunWith(SpringJUnit4ClassRunner.class)
//告诉junit spring配置文件
@ContextConfiguration({ "classpath:applicationContext.xml"})
public class MyTest {
    @Autowired
    UserService userService;
    @Autowired
    UserMapper userMapper;
    @Test
    public void Test02(){
        User user = userMapper.get("111","111");
        System.out.println(user.toString());
    }
}
