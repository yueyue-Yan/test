<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">

    <link href="/jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="/jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>

    <script type="text/javascript" src="/jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="/jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script>
        jQuery(function ($) {
            // 绑定表单的提交事件，表单提交时，会执行绑定的函数，如果函数返回true，则提交，否则不提交
            $("form").submit(function() {
                // selector1,selector2,...  ：组合选择器，结果为每个选择器的并集
                $("#typeCodeMsg,#valueMsg").text("");

                // 在该函数中对表单进行校验，如果不通过，返回false
                var typeCode = $("#typeCode").val();
                if (!typeCode) {
                    $("#typeCodeMsg").text("请选择字典类型！");
                }

                var value = $("#value").val();
                if(!value) {
                    $("#valueMsg").text("请填写字典值！");
                }

                // return false会阻止表单的提交（提交按钮的默认动作）
                return !!typeCode && !!value; // 双取反操作：将值转为boolean类型
                //return typeCode != "" && value != "";
            });

            $("#saveBtn").click(function () {
                // 调用提交方法，会触发绑定的事件
                $("form").submit();
            });
        });
    </script>
</head>
<body>

<div style="position:  relative; left: 30px;">
    <h3>新增字典值</h3>
    <div style="position: relative; top: -40px; left: 70%;">
        <button id="saveBtn" type="button" class="btn btn-primary">保存</button>
        <button type="button" class="btn btn-default" onclick="window.history.back();">取消</button>
    </div>
    <hr style="position: relative; top: -40px;">
</div>
<%--
    action:
    method:
    name:
--%>
<form action="/value/save.do" method="post" class="form-horizontal" role="form">

    <div class="form-group">
        <label for="typeCode" class="col-sm-2 control-label">字典类型编码<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" name="typeCode" id="typeCode" style="width: 200%;">
                <option value="">--请选择--</option>
                <c:forEach items="${tList}" var="t">
                    <option value="${t.code}">${t.name}</option>
                </c:forEach>
            </select>
            <div id="typeCodeMsg" style="color:red;"></div>
        </div>
    </div>

    <div class="form-group">
        <label for="value" class="col-sm-2 control-label">字典值<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" name="value" id="value" style="width: 200%;">
            <div id="valueMsg" style="color:red;"></div>
        </div>
    </div>

    <div class="form-group">
        <label for="text" class="col-sm-2 control-label">文本</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" name="text" id="text" style="width: 200%;">
        </div>
    </div>

    <div class="form-group">
        <label for="create-orderNo" class="col-sm-2 control-label">排序号</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" name="orderNo" id="create-orderNo" style="width: 200%;">
        </div>
    </div>
</form>

<div style="height: 200px;"></div>
</body>
</html>