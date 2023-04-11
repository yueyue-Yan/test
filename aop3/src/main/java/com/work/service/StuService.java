package com.work.service;

import com.work.beans.Stu;
import org.springframework.stereotype.Service;

@Service
public class StuService {
    public void addStu(int a, int b, Stu stu){

        System.out.println("addStu   "+a);
        System.out.println("addStu   "+b);
        System.out.println("addStu   "+stu.getName());
    }

    public void editStu(int a, int b){

        System.out.println("editStu   "+a);
        System.out.println("editStu   "+b);
    }
}
