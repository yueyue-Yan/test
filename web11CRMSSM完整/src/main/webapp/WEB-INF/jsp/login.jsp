<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link href="/jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="/jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="/jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script>
        // 如果当前窗口不是顶层窗口，让当前页面在顶层窗口展示
        if ( top !== window ) {
            top.location = location;
        }



        jQuery(function ($) {
            $("#loginBtn").click(function() {
                // 表单验证：非空验证
                var username = $("#username").val();
                if ( !username ) {
                    alert("请填写用户名！");
                    $("#username")[0].focus(); // 让元素获得焦点
                    return;
                }

                var password = $("#password").val();
                if ( !password ) {
                    alert("请填写密码！");
                    $("#password")[0].focus(); // 让元素获得焦点
                    return;
                }

                // 登录的用户名和密码数据
                var data = {
                    username: username,
                    password: password
                };

                // 如果用户勾选了免登录，则提交autoLogin，否则不提交
                if ( $("#autoLogin").prop("checked") ) {
                    data.autoLogin = $("#autoLogin").val();
                }

                $.ajax({
                    url: "/user/login.do",
                    type: "post", // post请求数据在请求体中，在加密协议下，会进行加密处理
                    data: data,
                    success: function (data) {
                        /**
                         * 可能的情况：
                         *  1. 用户名或密码错误
                         *  2. 您的账号已过期
                         *  3. 您的账号已锁定
                         *  4. 当前IP地址不允许登录
                         *  5. 登录成功，跳转到工作台首页
                         *
                         *  data: {
                         *      success: true/false,
                         *      msg: 字符串信息,
                         *      data: 渲染页面需要的数据，数组或对象
                         *  }
                         */

                        // 如果msg不为空，打印msg(错误信息)
                        if( data.msg ) {
                            alert(data.msg);
                        }
                        if ( data.success ) {
                            /**
                             * PageController
                             * "/workbench/index.jsp" ===> "workbench/index"
                             * "workbench/index"经过视图解析器解析后："/WEB-INF/jsp/" + "orkbench/index" + ".jsp"
                             */
                            location = "/workbench/indexView";
                        }
                    }
                });
            });
        });
    </script>
</head>
<body>
<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
    <img src="/image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
</div>
<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
    <div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">
        CRM &nbsp;<span style="font-size: 12px;">&copy;2020&nbsp;悦悦的小系统</span></div>
</div>

<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
    <div style="position: absolute; top: 0px; right: 60px;">
        <div class="page-header">
            <h1>登录</h1>
        </div>
        <form class="form-horizontal" role="form">
            <div class="form-group form-group-lg">
                <div style="width: 350px;">
                    <input id="username" class="form-control" value="zs" type="text" placeholder="用户名">
                </div>
                <div style="width: 350px; position: relative;top: 20px;">
                    <input id="password" class="form-control" value="123" type="password" placeholder="密码">
                </div>
                <div class="checkbox" style="position: relative;top: 30px; left: 10px;">
                    <label>
                        <input id="autoLogin" type="checkbox"> 十天内免登录
                    </label>
                </div>
                <button type="button" id="loginBtn" class="btn btn-primary btn-lg btn-block"
                        style="width: 350px; position: relative;top: 45px;">登录
                </button>
            </div>
        </form>
    </div>
</div>
</body>
</html>