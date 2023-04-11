package com.work.controller;

import com.work.beans.ActRemark;
import com.work.beans.Activity;
import com.work.beans.Page;
import com.work.beans.User;
import com.work.services.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/act")
public class ActivityController {
    @Autowired
    ActivityService activityService;

    @Autowired
    HttpServletRequest httpServletRequest;


    @RequestMapping("/indexView")
    public String indexView() {
        return "/workbench/activity/index";
    }

    @RequestMapping("/getAll.json")
    @ResponseBody
    public Page getAllJSON(Page page) {
        //System.out.println(page);
        //page中的data填充完毕，然后响应

        //总结：
        //1——功能类支持Page（分页参数、返回的数据集、查询参数map）
        //2——控制器接收前端参数为Page,响应前端结果为Page
        //3——业务接收Page参数,返回给控制器Page参数（对分页参数进行处理，填充返回数据集data数据）
        //4——dao需要getAll()和getCount两个方法支持
        //4-1——dao的getAll()接收分页参数，查询参数Map两个参数。并返回的数据集
        //4-2——dao的getCount()接收查询参数Map一个参数。并返回的带查询条件的总行数，用于计算
        return activityService.getAll(page);
    }

    @RequestMapping("/delete.do")
    @ResponseBody
    public Map deleteDo(@RequestParam("ids") String[] ids) {
        int delete = activityService.delete(ids);
        Map map = new HashMap();
        if (delete > 0) {
            map.put("success", true);
        } else {
            map.put("success", false);
        }
        return map;
    }

    @RequestMapping("/save.do")
    @ResponseBody
    public Map saveDo(Activity activity) {
        //添加前端没有给出的数据CreateBy
        HttpSession session = httpServletRequest.getSession();
        User user = (User) session.getAttribute("user");
        //利用session将用户账号loginAct设置为activity表中的创建者(CreateBy)
        activity.setCreateBy(user.getLoginAct());
        //调用service
        int save = activityService.save(activity);
        Map map = new HashMap();
        if (save > 0) {
            map.put("success", true);
        } else {
            map.put("success", false);
        }
        return map;
    }

    //1. 用于修改（edit），不填充remarks
    @RequestMapping("/get.json")
    @ResponseBody
    //经过对前端的分析发现
    // 传入参数是String类型的id:因为$("#editForm").initForm("/act/get.json?id="+id);
    // 要我们返回的参数是一个activity对象：因为form的div中name="id" name="owner" name="name" name="startDate" ...
    public Activity getJson(@RequestParam("id") String id) {
        return activityService.get(id);
    }

    //2. 用于备注查询（活动详细情况）
    @RequestMapping("/getRemark.json")
    @ResponseBody
    public Activity getRemarkJSON(@RequestParam("id") String id) {
        Activity remarks = activityService.getRemarks(id);
        return remarks;
    }

    @RequestMapping("update.do")
    @ResponseBody
    public Map updateDo(Activity activity) {
        //session记录一下谁修改的（EditBy）
        HttpSession session = httpServletRequest.getSession();
        User user = (User) session.getAttribute("user");
        activity.setEditBy(user.getLoginAct());

        int edit = activityService.edit(activity);
        Map map = new HashMap();
        if (edit > 0) {
            map.put("success", true);
        } else {
            map.put("success", false);
        }
        return map;
    }

    @RequestMapping("/detailIndexView")
    public String detailIndexView() {
        return "/workbench/activity/detail";
    }

    //remarks删除
    @RequestMapping("/delRemark.do")
    @ResponseBody
    public Map delRemarkDo(@RequestParam("id") String id) {
        Map map = new HashMap();
        int i = activityService.deleteRemarks(id);
        if (i > 0) {
            map.put("success", true);
        } else {
            map.put("success", false);
        }
        return map;
    }

    //remarks的添加或修改的保存
    //这里一定要注意，控制层要干什么，业务层要干什么
    //控制层负责与请求和响应有关的事情(例如session，cookies)，因为期内包含了请求和响应对象（只要涉及到需要依赖请求和响应对象的都属于请求和响应相关的事）
    //业务层做其他需求，负责调用dao层，过度给controller
    @RequestMapping("/saveRemark.do")
    @ResponseBody
    public Map saveRemarkDo(ActRemark actRemark) {
        //System.out.println(actRemark);
        Map map = new HashMap();
        HttpSession session = httpServletRequest.getSession();
        User user = (User) session.getAttribute("user");
        String name = user.getName();

        if (actRemark.getId() == null) {
            //添加
            actRemark.setNotePerson(name);
        } else {
            //修改
            actRemark.setEditPerson(name);
        }
        //调用业务层填充其他属性
        int i = activityService.saveRemark(actRemark);

        if (i > 0) { map.put("success", true); }
        else { map.put("success", false); }
        return map;
    }
}
