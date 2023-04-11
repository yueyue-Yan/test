package com.work.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/settings")
public class SettingsController {
    @RequestMapping("/indexView")
    public String indexView(){
        return "/settings/index";
    }
}
