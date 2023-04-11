package com.work.controller;


import com.work.beans.Type;
import com.work.beans.Value;
import com.work.services.TypeService;
import com.work.services.ValueService;
import com.work.tools.UUIDUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;


import java.util.List;

@Controller
@RequestMapping("/value")
public class ValueController {
    @Autowired
    ValueService valueService;
    @Autowired
    TypeService typeService;

    @RequestMapping("/indexView")
    public String indexView(Model model){
        List<Value> all = valueService.getAll();
        model.addAttribute("vList",all);
        return "/settings/dictionary/value/index";
    }

    @RequestMapping("/saveView")
    public String saveView(Model model){
        List<Type> all = typeService.getAll();
        model.addAttribute("tList",all);
        return "/settings/dictionary/value/save";
    }

    @RequestMapping("/save.do")
    public String saveDo(Value value){
        value.setId(UUIDUtils.getUUID());
        valueService.save(value);
        return "redirect:/value/indexView";
    }
    @RequestMapping("/editView")
    public String editView(@RequestParam("id")String id, Model model){
        Value value = valueService.get(id);
        model.addAttribute("value",value);
        List<Type> all = typeService.getAll();
        model.addAttribute("tList",all);
        return "/settings/dictionary/value/edit";
    }
    @RequestMapping("/edit.do")
    public String editDo(Value value){
        valueService.edit(value);
        return "redirect:/value/indexView";
    }
    @RequestMapping("/delete.do")
    public String deleteDo(String[] ids){
        valueService.delete(ids);
        return "redirect:/value/indexView";
    }

}
