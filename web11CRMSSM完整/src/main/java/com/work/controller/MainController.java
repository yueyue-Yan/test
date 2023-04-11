package com.work.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;


@Controller
@RequestMapping("/main")
public class MainController {
    @RequestMapping("/indexView")
    public String indexView(){
        return "/workbench/main/index";
    }
}
