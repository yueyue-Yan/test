package com.work.test;

import com.work.beans.Stu;
import com.work.service.StuService;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

//设置Spring测试启动类
@RunWith(SpringJUnit4ClassRunner.class)
//告诉junit spring配置文件
@ContextConfiguration({"classpath:applicationContext.xml"})
public class MyTest {
    @Autowired
    StuService stuService;

    @Test
    public void Test00() {
        Stu stu=new Stu();
        stuService.addStu(15,20,stu);

    }
    @Test
    public void Test01() {
        stuService.editStu(5,15);
    }
}
