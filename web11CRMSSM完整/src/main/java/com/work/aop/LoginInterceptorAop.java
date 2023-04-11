package com.work.aop;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
@Component
@Aspect
public class LoginInterceptorAop {
    @AfterReturning(
            value="execution(boolean com.work.interceptor.LoginInterceptor.preHandle(..))",
            returning = "flag")
    public void loginInterceptorLog(JoinPoint joinPoint,boolean flag){
        Object[] args = joinPoint.getArgs();
        HttpServletRequest request = (HttpServletRequest) args[0];
        String requestURI = request.getRequestURI();
        System.out.println("AOP切登录拦截器拦截的地址为： "+requestURI+"----"+flag);
    }

}
