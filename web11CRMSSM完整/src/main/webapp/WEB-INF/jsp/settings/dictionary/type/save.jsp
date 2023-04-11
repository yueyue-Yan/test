<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">

    <link href="/jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="/jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="/jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="/jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script>
        jQuery(function ($) {
            // 给保存按钮绑定事件
            $("#saveBtn").click(function () {
                // 重新校验...
                var code = $("#code").val();
                $("#errMsg").text("");
                if ( !checkCode(code) ) {
                    // 红色文字提示
                    $("#errMsg").text("只能由字母、数字、下划线组成，字母开头。");
                } else {
                    // 发送ajax请求
                    $.ajax({
                        url: "/type/check.do?code=" + code,
                        success: function (exists) {
                            if(exists) {
                                $("#errMsg").text("编码重复了！");
                            } else {
                                // 可以提交
                                $("#saveForm").submit();
                            }
                        }
                    });
                }
            });

            // 返回true，表示通过
            function checkCode(code) {
                // ? 表示匹配前面的子表达式0此或1次
                // + 表示匹配前面的子表达式1此或多次
                // * 表示匹配前面的子表达式0此或多次
                // i ignore 忽略大小写
                var reg = /^[a-z][a-z0-9_]*$/i;

                return reg.test(code);
            }

            //1. 只能由字母、数字、下划线组成（实时校验）
            $("#code").on("input", function () {
                $("#errMsg").text(""); // 清空错误信息

                if (!checkCode(this.value)) {
                    // 红色文字提示
                    $("#errMsg").text("只能由字母、数字、下划线组成，字母开头。");
                }
            }).
            // 2. 不能重复，需要使用ajax技术来完成（离焦之后校验）
            on("blur", function() {
                if (checkCode(this.value)) {
                    $("#errMsg").text("");

                    // 发送ajax请求
                    $.ajax({
                        url: "/type/check.do?code=" + this.value,
                        success: function (exists) {
                            if(exists) {
                                $("#errMsg").text("编码重复了！");
                            }
                        }
                    });
                }
            });
        });
    </script>
</head>
<body>

<div style="position:  relative; left: 30px;">
    <h3>新增字典类型</h3>
    <div style="position: relative; top: -40px; left: 70%;">
        <button id="saveBtn" type="button" class="btn btn-primary">保存</button>
        <button type="button" class="btn btn-default" onclick="window.history.back();">取消</button>
    </div>
    <hr style="position: relative; top: -40px;">
</div>
<%--
    action
    method
    表单元素的name属性和类中一致
--%>
<form id="saveForm" action="/type/save.do" method="post" class="form-horizontal" role="form">
    <div class="form-group">
        <label for="code" class="col-sm-2 control-label">编码<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" name="code" id="code" style="width: 200%;"
                   placeholder="1. 只能由字母、数字和下划线组成; 2. 编码作为主键，不能重复(AJAX)">
            <div id="errMsg" style="color:red;width: 500px;"></div>
        </div>
    </div>

    <div class="form-group">
        <label for="tname" class="col-sm-2 control-label">名称</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" name="name" id="tname" style="width: 200%;">
        </div>
    </div>

    <div class="form-group">
        <label for="description" class="col-sm-2 control-label">描述</label>
        <div class="col-sm-10" style="width: 300px;">
            <textarea class="form-control" rows="3" name="description" id="description" style="width: 200%;"></textarea>
        </div>
    </div>
</form>

<div style="height: 200px;"></div>
</body>
</html>