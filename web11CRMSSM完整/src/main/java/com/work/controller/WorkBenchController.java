package com.work.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/workbench")
public class WorkBenchController {
    @RequestMapping("/indexView")
    public String indexView(){
        return "/workbench/index";
    }
}
