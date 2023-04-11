<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link href="/jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>

    <script type="text/javascript" src="/jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="/jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/jquery/jquery.bs_alert.js"></script>
    <script>
        jQuery(function ($) {
            $("#createBtn").click(function () {
                // 请求后台查询字典类型，因为添加页面需要选择字典值对应的类型
                location = "/value/saveView";
            });

            $("#editBtn").click(function () {
                // 获取选中的复选框
                var $cks = $(":checkbox[name=id]:checked");
                // 编辑只能选择1条数据
                if ( $cks.size() == 0 ) {
                    $.alert("请选择编辑项！");
                    return ;
                }

                if ( $cks.size() > 1 ) {
                    $.alert("只能选择一项进行编辑！");
                    return ;
                }

                // 请求后台查询字典值信息，在编辑页面进行数据的回显
                location = '/value/editView?id=' + $cks.val();
            });

            // 删除
            $("#delBtn").click(function () {
                var arr = [];
                $(":checkbox[name=id]:checked").each(function () {
                    // this是DOM对象，可以直接使用DOM的方式获取值
                    // jQuery获取值的方式：$(this).val()
                    arr.push(this.value);
                });

                if(arr.length == 0) {
                    $.alert("请选择删除项！");
                    return;
                }

                $.confirm("确定删除吗？", function () {
                    // delete.do?ids=1,2,3
                    // delete.do?id=1&id=2&id=3
                    location = "/value/delete.do?ids=" + arr.join(",");
                });
            });

            // 全选
            $("#selectAll").click(function () {
                $(":checkbox[name=id]").prop("checked", this.checked);
            });

            $(":checkbox[name=id]").click(function () {
                $("#selectAll").prop("checked", $(":checkbox[name=id]").size() == $(":checkbox[name=id]:checked").size());
            });
        });
    </script>
</head>
<body>

<div>
    <div style="position: relative; left: 30px; top: -10px;">
        <div class="page-header">
            <h3>字典值列表</h3>
        </div>
    </div>
</div>
<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;left: 30px;">
    <div class="btn-group" style="position: relative; top: 18%;">
        <button id="createBtn" type="button" class="btn btn-primary">
            <span class="glyphicon glyphicon-plus"></span> 创建
        </button>
        <button id="editBtn" type="button" class="btn btn-default">
            <span class="glyphicon glyphicon-edit"></span> 编辑
        </button>
        <button id="delBtn" type="button" class="btn btn-danger">
            <span class="glyphicon glyphicon-minus"></span> 删除
        </button>
    </div>
</div>
<div style="position: relative; left: 30px; top: 20px;">
    <table class="table table-hover">
        <thead>
        <tr style="color: #B3B3B3;">
            <td><input id="selectAll" type="checkbox"/></td>
            <td>序号</td>
            <td>字典值</td>
            <td>文本</td>
            <td>排序号</td>
            <td>字典类型</td>
        </tr>
        </thead>
        <tbody>
            <c:forEach items="${vList}" var="v" varStatus="sta">
            <tr class="${sta.index%2==0?'active':''}">
                <td><input name="id" type="checkbox" value="${v.id}"/></td>
                <td>${sta.count}</td>
                <td>${v.value}</td>
                <td>${v.text}</td>
                <td>${v.orderNo}</td>
                <%--显示字典类型名称--%>
                <td>${v.type.name}</td>
            </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

</body>
</html>