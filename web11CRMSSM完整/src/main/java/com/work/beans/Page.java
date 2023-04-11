package com.work.beans;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * 分页对象
 * 需要在后台计算的属性有：
 * 1. 总记录数，select count(*) from xxx
 * 2. 总页数，需要根据总记录数和每页条数进行计算
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
//重要：三合一：分页，查询，结果集

//总结：
//1——功能类支持Page（分页参数、返回的数据集、查询参数map）
//2——控制器接收前端参数为Page,响应前端结果为Page
//3——业务接收Page参数,返回给控制器Page参数（对分页参数进行处理，填充返回数据集data数据）
//4——dao需要getAll()和getCount两个方法支持
//4-1——dao的getAll()接收分页参数，查询参数Map两个参数。并返回的数据集
//4-2——dao的getCount()接收查询参数Map一个参数。并返回的带查询条件的总行数，用于计算

//page算是功能beans，非表格beans
// page不同于ORM（关系映射/表格）beans，例如Type，Value，Activity都属于ORM beans，因为数据库中有其对应的表
public class Page implements Serializable {
    //1. 分页
    private Integer currentPage = 1;        // 当前页（查询条件）
    private Integer rowsPerPage = 10;       // 每页显示的记录条数（查询条件）
    private Integer maxRowsPerPage = 100;   // 每页最多显示的记录条数(配置)
    private Integer totalPages;             // 总页数（需要计算）
    private Integer totalRows;              // 总记录数（需要计算）
    private Integer visiblePageLinks = 5;   // 显示几个卡片(配置)

    //3. 结果集
    private List data;//数据集

    //2. 查询
    private Map<String, Object> searchMap; // 查询条件


}
