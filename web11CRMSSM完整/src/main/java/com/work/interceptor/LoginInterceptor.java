package com.work.interceptor;

import com.work.beans.User;
import com.work.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

//需要配置，
//在SpringMVC配置
public class LoginInterceptor implements HandlerInterceptor {

    @Autowired
    UserService userService;


    //准备方法：请求到达控制器或者响应之前
    //return false拦截请求 return true放行
    //Object handler 就是控制器的方法对象【例如LoginController类中的loginDo方法】

    //放行两种情况
    //1-- 有session
    //2-- 没session有cookie，cookie里有sessionID
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        //获取session
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            //无session看看有无cookies
            String loginAct = null;
            String loginPwd = null;
            Cookie[] cookies = request.getCookies();
            //取出cookies
            if (cookies != null) {
                for (Cookie c : cookies) {
                    if (c.getName().equals("loginAct")) {
                        loginAct = c.getValue();
                    }
                    if (c.getName().equals("loginPwd")) {
                        loginPwd = c.getValue();
                    }
                }
            }
            //是否真正都取出来了：是否用户名和密码都存在
            if (loginAct != null && loginPwd != null) {
                //用户名和密码存在【任何地址都可以执行userServices.login】
                // //【userServices.login该方法会触发异常，且LoginControllerAdvice会捕获异常】

                //拦截器调业务层进行用户身份条件核实：例如IP范围，锁定状态等
                User user = userService.login(loginAct, loginPwd);
                //再次进入session
                session.setAttribute("user", user);
                //放行
                return true;
            }
            //不符合登陆条件
            //重定向
            response.sendRedirect("/user/loginView");
            //不放行
            return false;
        }
        //如果session存在
        else {
            //放行
            return true;
        }

    }










    //SpringMVC的ModeAndView生成之后，界面渲染之前
    //ModelAndView modelAndView参数就是生成的modelAndView
    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {

    }

    //渲染视图之后，【响应】
    //Exception ex:响应的时候发生异常
    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {

    }
}
