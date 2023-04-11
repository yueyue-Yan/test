package com.work.controller;

import com.work.beans.Type;
import com.work.services.TypeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
@RequestMapping("/type")
public class TypeController {
    @Autowired
    TypeService typeService;

    @RequestMapping("/indexView")
    public String indexView(Model model){
        List<Type> all = typeService.getAll();
        model.addAttribute("tList",all);
        return "/settings/dictionary/type/index";
    }
    @RequestMapping("/saveView")
    public String saveView(){
        return "/settings/dictionary/type/save";
    }
    @RequestMapping("/check.do")
    @ResponseBody
    public boolean checkDo(@RequestParam("code") String code){
        Type type = typeService.get(code);

        return type==null?false:true;
    }
    @RequestMapping("/save.do")
    public String saveDo(Type type){
        typeService.save(type);
        return "redirect:/type/indexView";
    }
    @RequestMapping("/editView")
    public String editView(@RequestParam("code") String code,Model model){
        Type type = typeService.get(code);
        model.addAttribute("type",type);
        return "/settings/dictionary/type/edit";
    }
    @RequestMapping("/edit.do")
    public String editDo(Type type){
        typeService.edit(type);
        return "redirect:/type/indexView";
    }

    @RequestMapping("/delete.do")
    public String deleteDo(@RequestParam("ids") String[] ids){
        typeService.delete(ids);
        return "redirect:/type/indexView";
    }

}
