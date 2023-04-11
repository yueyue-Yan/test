package com.work.services;

import com.work.mapper.ChartMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class ChartServiceImpl implements ChartServicce {
    @Autowired
    ChartMapper chartMapper;

    List months = new ArrayList(){{
        add(1); add(2); add(3); add(4); add(5); add(6); add(7); add(8); add(9); add(10); add(11); add(12);
    }};
    @Override
    public List activityChart(int year) {
        return chartMapper.activityChart(year,months);
    }
}
