<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">

    <link href="/jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="/jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet"/>

    <script type="text/javascript" src="/jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="/jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/jquery/jquery.bs_alert.js"></script>
    <script>
        jQuery(function ($) {
            // 表单提交时，执行绑定的函数进行表单验证，验证不通过，返回false，表单就不会提交
            $("form").submit(function() {
                // 字典值的非空验证
                var dicValue = $("#edit-dicValue").val();
                if(!dicValue) {
                    //$.alert("字典值不能为空！");
                    $("#dicValueErrMsg").text("字典值不能为空！");
                    $("#edit-dicValue")[0].focus();
                    return false;
                }
                return true;
            });

            $("#updateBtn").click(function () {
                // 提交表单，会触发绑定函数对表单进行校验
                $("form").submit();
            });
        });
    </script>
</head>
<body>

<div style="position:  relative; left: 30px;">
    <h3>修改字典值</h3>
    <div style="position: relative; top: -40px; left: 70%;">
        <button id="updateBtn" type="button" class="btn btn-primary">更新</button>
        <button type="button" class="btn btn-default" onclick="window.history.back();">取消</button>
    </div>
    <hr style="position: relative; top: -40px;">
</div>
<%--
    action
    method
    name
--%>
<form action="/value/edit.do" method="post" class="form-horizontal" role="form">
    <input type="hidden" name="id" value="${value.id}" />
    <div class="form-group">
        <label for="typeCode" class="col-sm-2 control-label">字典类型编码<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" name="typeCode" id="typeCode" style="width: 200%;">
                <c:forEach items="${tList}" var="t">
                    <option value="${t.code}" ${value.typeCode eq t.code ? "selected": ""}>${t.name}</option>
                </c:forEach>
            </select>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-dicValue" class="col-sm-2 control-label">字典值<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" name="value" id="edit-dicValue" style="width: 200%;" value="${value.value}">
            <div id="dicValueErrMsg" style="color:red;"></div>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-text" class="col-sm-2 control-label">文本</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" name="text" id="edit-text" style="width: 200%;" value="${value.text}">
        </div>
    </div>

    <div class="form-group">
        <label for="edit-orderNo" class="col-sm-2 control-label">排序号</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" name="orderNo" id="edit-orderNo" style="width: 200%;" value="${value.orderNo}">
        </div>
    </div>
</form>

<div style="height: 200px;"></div>
</body>
</html>