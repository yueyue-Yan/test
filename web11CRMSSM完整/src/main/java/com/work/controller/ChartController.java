package com.work.controller;

import com.work.beans.Value;
import com.work.services.ChartServicce;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.lang.model.util.AbstractAnnotationValueVisitor6;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/chart")
public class ChartController {
    @Autowired
    ChartServicce chartServicce;

    @RequestMapping("/transaction/indexView")
    public String transactionIndexView(){
        return "workbench/chart/transaction/index";
    }

    @RequestMapping("/transaction/getStageCount.json")
    @ResponseBody
    public Map transactionGetStageCountJSON(){
        return null;
    }

    @RequestMapping("/activity/indexView")
    public String activityIndexView(){
        return "workbench/chart/activity/index";
    }
    @RequestMapping("/activity/getStageCount.json")
    @ResponseBody
    public List<Integer> activityGetStageCountJSON(@RequestParam("year") int year ){
        //图表展示需求一般考验的是SQL语句查询能力
        //根据年份查出每个月活动的成本和
        //如何显示出来
        //data:[0,0,0,0,0,0,0,0,0,0,0,0]

        List list = chartServicce.activityChart(year);

        return list;
    }

}
