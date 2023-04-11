package com.work.controller.advice;


import com.work.exception.LoginRuntimeException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
//增强控制器

@ControllerAdvice
public class LoginControllerAdvice {
    @Autowired
    HttpServletRequest httpServletRequest;
    @Autowired
    HttpServletResponse httpServletResponse;

    @ExceptionHandler(LoginRuntimeException.class)

    @ResponseBody
    public Map loginException(LoginRuntimeException e) throws IOException {
        Map map = new HashMap();

            //增强控制器，返回的JSON哪个页面可以接收（"/user/login.do"），那么就让哪个页面接收
            //增强控制器，不一定都是可以接收JSON的页面发出的请求（例如"/settings/indexView"），因此需要判断
        String requestURI = httpServletRequest.getRequestURI();
//        System.out.println("requestURI,,,,,,,,,,:" + requestURI);
        //不能接收增强控制器返回结果的页面请求，需要处理，一般都会进行跳转或者重定向
        if(! requestURI.equals("/user/login.do")){
            httpServletResponse.sendRedirect("/user/loginView");
        }

        String message = e.getMessage();
        map.put("msg",message);
        return map;
    }
}
