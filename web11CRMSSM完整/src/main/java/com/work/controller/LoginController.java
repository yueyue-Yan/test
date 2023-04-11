package com.work.controller;

import com.work.beans.User;

import com.work.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/user")
public class LoginController {
    @Autowired
    UserService userService;
    //拿出sessionID需要请求对象的协助
    @Autowired
    HttpServletRequest httpServletRequest;

    @Autowired
    HttpServletResponse httpServletResponse;

    @RequestMapping("/loginView")
    public String loginView() {

        return "/login";
    }

    @RequestMapping("/login.do")
    @ResponseBody
    public Map loginDo(String username, String password, String autoLogin) {
        Map map = new HashMap();
        //调用service层做账号密码的各种相关判定
        User user = userService.login(username, password);
        //运行到此处说明登陆成功
        //如果选择十天免登录，要记录cookies
        //1-- cookies不能关闭，浏览器可以关闭
        //2--记录cookies，cookies是键值对，只是记录比较简单的数据
        //3--cookies怎木出来？
        if(autoLogin != null){
      //if(autoLogin.equals("on")){        会报错:Null Pointer Exception，因为autoLogin不被选中时是null
            //1. 创建cookie
            Cookie loginActCookie = new Cookie("loginAct",username);
            Cookie LoginPwdCookie = new Cookie("loginPwd",password);
            //2. 设置cookie：有效时间十天10*24*60*60
            loginActCookie.setMaxAge(10*24*60*60);
            LoginPwdCookie.setMaxAge(10*24*60*60);
            //3. 页面作用域
            loginActCookie.setPath("/");
            LoginPwdCookie.setPath("/");
            //4. 响应到客户端
            httpServletResponse.addCookie(loginActCookie);
            httpServletResponse.addCookie(LoginPwdCookie);
        }

        //需要把用户存储在session里面，让浏览器其他页面都知道
        HttpSession session = httpServletRequest.getSession();
        session.setAttribute("user",user);
        //map.put("msg", "登陆成功！");
        map.put("success", true);
        return map;
    }

    @RequestMapping("/logout.do")
    public String logoutDo(){

        HttpSession session = httpServletRequest.getSession();
        session.removeAttribute("user");

        //cookie不能删除只能覆盖(替换)
        Cookie loginActCookie = new Cookie("loginAct","");
        Cookie LoginPwdCookie = new Cookie("loginPwd","");
        //MaxAge设置为0
        loginActCookie.setMaxAge(0);
        LoginPwdCookie.setMaxAge(0);
        //作用域
        loginActCookie.setPath("/");
        LoginPwdCookie.setPath("/");
        //响应到客户端
        httpServletResponse.addCookie(loginActCookie);
        httpServletResponse.addCookie(LoginPwdCookie);

        return "redirect:/user/loginView";
    }
    @RequestMapping("/getAllUserName.json")
    @ResponseBody
    public List<String> getAllUserNameJSON(){
        return userService.getAllUserNameJSON();
    }

//    public String[] getAllUserNameJSON(){
//        List<User> all = userService.getAll();
//        int size = all.size();
//        String[] temp = new String[size];
//        for(int i=0;i<size;i++){
//            // data: ["工号 | zhangsan", "工号 | lisi", ...]
//            String tempUser = all.get(i).getLoginAct() + "|" + all.get(i).getName();
//            temp[i] = tempUser;
//    }
//        return temp;
//}


}













