package com.work.beans;

import org.springframework.stereotype.Component;


public class Stu {
    String name;

    public Stu(String name) {
        this.name = name;
    }
    public Stu() {
    }



    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}