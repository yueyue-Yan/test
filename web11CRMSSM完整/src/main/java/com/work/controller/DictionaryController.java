package com.work.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/settings/dictionary")
public class DictionaryController {
    @RequestMapping("/indexView")
    public String indexView(){
        return "/settings/dictionary/index";
    }
}
