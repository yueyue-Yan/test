package com.work.aop;

import com.work.beans.Stu;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.stereotype.Component;

//AOP参数传递两个办法

//1——使用方法参数JoinPoint
//JoinPoint该参数除了环绕通知没有，其他通知都有
//jp.getArgs()切点传递过来的参数
//jp.getSignature()切点的信息
//jp.getTarget()切点所在类的对象
//jp.getThis()切面代理对象

//环绕通知有ProceedingJoinPoint,而且ProceedingJoinPoint是JoinPoint孩子
//ProceedingJoinPoint会多一个proceed()方法，判定切点执行与否




//2——利用注解属性argNames传递参数【使用几率很少】
//需要知道一些AspectJ的注解语法规则
//argNames="参数列表"配合execution(.....) && args(参数列表)
//切面方法参数配合public void pt2(参数列表)
//数据类型错误，通知不执行




//3——可以使用方法参数JoinPoint和注解属性argNames一起使用
//JoinPoint必须放在参数列表的最前面

@Component
@Aspect
public class StuAop {
    @Pointcut("execution(* com.work.service.StuService.addStu(..))")
    private void pointCut(){

    }
    @Pointcut(argNames = "a,b", value="execution(* com.work.service.StuService.editStu(..))&& args(a,b)")
    private void pointCut2(int a,int b){

    }
//1. JoinPoint（推荐！）
    @Before("pointCut()")
    public void stuFun1(JoinPoint jp){
        Object[] args = jp.getArgs();
        System.out.println("stuFun1====================="+args[0]);
        args[1]=(int)args[1]+50;
        System.out.println("stuFun1====================="+args[1]);
        Stu temp = ((Stu)args[2]);
        System.out.println("stuFun1====================="+temp.getName());
        temp.setName("yy");
        System.out.println("stuFun1====================="+temp.getName());

    }
    @Around("pointCut()")
    public void stuFun2(ProceedingJoinPoint pjp) throws Throwable {
        System.out.println("up");
        pjp.proceed();
        System.out.println("down");
    }
    @After("pointCut()")
    public void stuFun3(JoinPoint jp){

    }
    @AfterReturning(value = "pointCut()",returning = "result")
    public void stuFun4(JoinPoint jp,Object result){

    }
    @AfterThrowing(value = "pointCut()",throwing = "ex")
    public void stuFun5(JoinPoint jp,Throwable ex){

    }
    //2. 注解属性（不推荐）
    @Before("pointCut2(a,b)")
    public  void  stuFun6(JoinPoint jp,int a,int b){
        System.out.println("stuFun6:"+(a+100));
    }

}
