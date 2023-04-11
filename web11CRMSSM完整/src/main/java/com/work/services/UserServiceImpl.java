package com.work.services;

import com.work.beans.User;
import com.work.exception.LoginRuntimeException;
import com.work.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;

@Service
public class UserServiceImpl implements UserService{
    @Autowired
    UserMapper userMapper;
    //使用该对象的条件是：controller调用了services，
    // 而controller会自动得到传递HttpServletRequest对象
    //测试的时候必须具备Springmvc环境才可以测试该业务类
    //险棋，奇招，奥妙
    @Autowired
    HttpServletRequest httpServletRequest;

    @Override
    public User login(String username, String password) {

        User user = userMapper.get(username,password);

        //让业务层来判断用户的账号密码是否登录正确，如果正确controller层直接调用user即可，如果不正确则在service层就断开
        //简言之，就是不再在controller层判断用户是否登陆成功而是交给service解决这个判断
        //业务层拥有判断错误的能力

        //1--业务层可以支持各种错误的判断
        //2-- 业务层可以触发各种运行时异常，传递异常信息
        //3-- 业务层不触发异常，意味着一定正确
        //①用户账号密码错误
        if(user==null){
           // 断开：抛出异常?
            //System.out.println("用户密码错误");
           // throw  new RuntimeException();
            throw new LoginRuntimeException("用户名或密码错误 User name or password error.");
        }
        //②是否过期
        //用户到期时间
        String expireTime = user.getExpireTime();

        LocalDateTime userExpireTime = LocalDateTime.parse(expireTime, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        //系统时间
        LocalDateTime now = LocalDateTime.now();
        if(now.isAfter(userExpireTime)){
            throw new LoginRuntimeException("账号过期了！");
        }

        //③用户锁定
        String lockStatus = user.getLockStatus();
        if(lockStatus.equals("0")){
            throw new LoginRuntimeException("账号已经被锁定！");
        }
        //④IP范围
        String[] ips = user.getAllowIps().split(",");
        List<String> listIps = Arrays.asList(ips);
        //得到当前IP
        String remoteAddr = httpServletRequest.getRemoteAddr();
        System.out.println(remoteAddr);
        if(! listIps.contains(remoteAddr)){
            throw new LoginRuntimeException("IP不在允许范围内");
        }
        return user;
    }


    @Override
    public List<String> getAllUserNameJSON() {
        return userMapper. getAllJSON();
    }
}
