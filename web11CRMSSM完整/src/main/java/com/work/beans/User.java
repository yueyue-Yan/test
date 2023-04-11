package com.work.beans;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class User implements Serializable {
    String id;
    String deptId;
    //账号
    String loginAct;
    String name;
    //密码【MD5】
    String loginPwd;
    String email;
    //过期时间【时间过期不能登录，日期】
    String expireTime;
    //账号锁定状态【0锁定，1开放】
    String lockStatus;
    //允许IP地址范围【IP地址,IP地址,IP地址】
    String allowIps;
    String createBy;
    String createTime;
    String editBy;
    String editTime;
}
