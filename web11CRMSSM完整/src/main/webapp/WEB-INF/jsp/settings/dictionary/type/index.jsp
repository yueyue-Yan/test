<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <%@include file="/WEB-INF/jsp/include/commons_head.jsp" %>
    <script>
        jQuery(function ($) {
            // 编辑按钮事件绑定
            $("#editBtn").click(function() {
                // 获取选中的类型
                var $cks = $(":checkbox[name=code]:checked");
                if ($cks.size() == 0) {
                    alert("请选择要编辑的字典类型！");
                    return ;
                }
                if ($cks.length > 1) {
                    alert("只能选择一个字典类型！");
                    return ;
                }

                location = "/type/editView?code="+$cks.val();

            });


            // 全选
            $("#selectAll").selectAll(":checkbox[name=code]");

            $("#delBtn").click(function () {
                // 获取选中的类型
                var $cks = $(":checkbox[name=code]:checked");
                if ($cks.size()==0) {
                    alert("请选择删除项！");
                    return ;
                }

                if(!confirm("确定删除吗？")) {
                    return ;
                }

                var arr = [];
                $cks.each(function() {
                    // push方法向数组中存值
                    arr.push(this.value);
                });

                // join方法将数组中的元素以指定的字符串连接，返回连接后的字符串
                var ids = arr.join(",");

                location = "/type/delete.do?ids=" + ids;

            });
        });
    </script>
</head>
<body>

<div>
    <div style="position: relative; left: 30px; top: -10px;">
        <div class="page-header">
            <h3>字典类型列表</h3>
        </div>
    </div>
</div>
<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;left: 30px;">
    <div class="btn-group" style="position: relative; top: 18%;">
        <button type="button" class="btn btn-primary" onclick="location='/type/saveView'"><span
                class="glyphicon glyphicon-plus"></span> 创建
        </button>
        <button id="editBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-edit"></span> 编辑
        </button>
        <button id="delBtn" type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除
        </button>
    </div>
</div>
<div style="position: relative; left: 30px; top: 20px;">
    <table class="table table-hover">
        <thead>
        <tr style="color: #B3B3B3;">
            <td><input id="selectAll" type="checkbox"/></td>
            <td>序号</td>
            <td>编码</td>
            <td>名称</td>
            <td>描述</td>
        </tr>
        </thead>
        <tbody>
        <%--
            sta:
                sta.index  索引，从0开始
                sta.count  序号，从1开始
        --%>
        <c:forEach items="${ tList }" var="t" varStatus="sta">
            <tr class="${sta.index%2==0?'active':''}">
                <td><input name="code" type="checkbox" value="${t.code}" /></td>
                <td>${sta.count}</td>
                <td>${t.code}</td>
                <td>${t.name}</td>
                <td>${t.description}</td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
</div>

</body>
</html>