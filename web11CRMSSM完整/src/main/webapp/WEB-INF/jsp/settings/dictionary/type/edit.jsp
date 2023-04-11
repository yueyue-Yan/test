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
            // 编辑按钮事件绑定
            $("#updateBtn").click(function() {

                // 提交表单
                $("form").submit();

            });
        });
    </script>
</head>
<body>

<div style="position:  relative; left: 30px;">
    <h3>修改字典类型</h3>
    <div style="position: relative; top: -40px; left: 70%;">
        <button id="updateBtn" type="button" class="btn btn-primary">更新</button>
        <button type="button" class="btn btn-default" onclick="window.history.back();">取消</button>
    </div>
    <hr style="position: relative; top: -40px;">
</div>
<%--
    action:
    method: post
    表单元素的name属性和类中的属性名一致
--%>
<form action="/type/edit.do" method="post" class="form-horizontal" role="form">

    <div class="form-group">
        <label for="code" class="col-sm-2 control-label">编码<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" name="code" id="code" style="width: 200%;" readonly
                   value="${type.code}">
        </div>
    </div>

    <div class="form-group">
        <label for="tname" class="col-sm-2 control-label">名称</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" required="required" name="name" id="tname" style="width: 200%;" value="${type.name}">
        </div>
    </div>

    <div class="form-group">
        <label for="describe" class="col-sm-2 control-label">描述</label>
        <div class="col-sm-10" style="width: 300px;">
            <textarea class="form-control" rows="3" name="description" id="describe"
                      style="width: 200%;">${type.description}</textarea>
        </div>
    </div>
</form>

<div style="height: 200px;"></div>
</body>
</html>