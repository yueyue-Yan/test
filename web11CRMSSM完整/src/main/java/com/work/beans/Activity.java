package com.work.beans;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Activity implements Serializable {
    String id;
    String owner;
    String name;
    String startDate;
    String endDate;
    String cost;
    //int cost;
    String description;
    String createBy;
    String createTime;
    String editBy;
    String editTime;

    //1. edit时会根据id查找到某一个Activity，此时不需要填充remarks集合。因为没必要且效率低
    //2. 显示备注的时候（detail.jsp）就需要填充remarks集合，但是也会根据id查找Activity
    List<ActRemark> remarks;

}
