<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/jsp/include/commons_head.jsp" %>
    <script type="text/javascript">

        jQuery(function ($) {

            $("input.time").datetimepicker({
                minView: "month",
                language:  'zh-CN',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "bottom-left"
            });

            $("#isCreateTransaction").click(function () {
                if (this.checked) {
                    $("#create-transaction2").show(200);
                } else {
                    $("#create-transaction2").hide(200);
                }
            });


            function load() {
                $.ajax({
                    url: "/clue/get.json?id=${param.id}",
                    success: function (data) {
                        // data中只包含线索信息，不包含备注列表
                        $("span[property]").each(function () {
                            $(this).text(data[$(this).attr("property")]);
                        });

                        $("#tradeName").val(data.company+"-");
                    }
                });
            }

            load();


            function loadAct() {
                // 加载所有市场活动
                $("#dataBody2").html("");
                $.ajax({
                    url: "/act/getAll2.json?actName="+$("#actName").val(),
                    success: function (data) {
                        $(data).each(function () {
                            $("#dataBody2").append(
                                '<tr>\
                                    <td><input name="id" actname="'+this.name+'" value="'+this.id+'" type="radio"/></td>\
                                    <td>'+this.name+'</td>\
                                    <td>'+this.startDate+'</td>\
                                    <td>'+this.endDate+'</td>\
                                    <td>'+this.owner+'</td>\
                                </tr>'
                            )
                        });
                    }
                });
            }

            $("#actSource").click(loadAct);

            $("#confirmBtn").click(function () {
                // 需要提交到后台，存放到隐藏域中
                var $radio = $(":radio:checked");
                var actId = $radio.val();
                var actName = $radio.attr("actname");

                $("#activityId").val(actId);
                // 市场活动名称赋值到输入框上
                $("#activityName").val(actName);

                $("#searchActivityModal").modal('hide');

            });

            $("#actName").keydown(function (e) {
                // 回车键
                if(e.which == 13) {
                    loadAct(); // 查询市场活动
                }
            });

            $("#convertBtn").click(function () {
                $.confirm("是否确定将该线索转换为客户？", function () {
                    // 线索ID
                    var data = {
                        clueId: "${param.id}"
                    };
                    // 如果勾选了创建交易，则还需要发送交易数据
                    if(data.createTran = $("#isCreateTransaction").prop("checked")) {
                        var tranObj = $("#tranForm").formJSON();
                        // extend方法将对象进行合并，合并规则，将所有属性合并到第一个参数中，如果存在相同的参数，则会覆盖
                        $.extend(data, tranObj);
                    }

                    $.ajax({
                        type: "post",
                        url: "/clue/convert.do",
                        data: data,
                        success: function (data) {
                            if(data.success) {
                                // 回到线索首页
                                $.alert("转换成功！", function () {
                                    location = "/workbench/clue/index.html";
                                });
                            }
                        }
                    })
                });
            });
        });
    </script>

</head>
<body>

<!-- 搜索市场活动的模态窗口 -->
<div class="modal fade" id="searchActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">搜索市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form action="javascript:;" class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input id="actName" type="text" class="form-control" style="width: 300px;"
                                   placeholder="请输入市场活动名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                    </tr>
                    </thead>
                    <tbody id="dataBody2"></tbody>
                </table>
            </div>


            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button id="confirmBtn" type="button" class="btn btn-danger">确定</button>
            </div>

        </div>
    </div>
</div>

<div id="title" class="page-header" style="position: relative; left: 20px;">
    <h4>转换线索
        <small><span property="fullName"></span><span property="appellation"></span>-<span property="company"></span></small>
    </h4>
</div>
<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
    新建客户：<span property="company"></span>
</div>
<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
    新建联系人：<span property="fullName"></span><span property="appellation"></span>
</div>
<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
    <input type="checkbox" id="isCreateTransaction"/>
    为客户创建交易
</div>
<div id="create-transaction2"
     style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;">

    <form id="tranForm">

        <input type="hidden" name="activityId" id="activityId" />

        <div class="form-group" style="width: 400px; position: relative; left: 20px;">
            <label for="amountOfMoney">金额</label>
            <input type="text" class="form-control" name="amountOfMoney" id="amountOfMoney">
        </div>
        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="tradeName">交易名称</label>
            <input type="text" class="form-control" id="tradeName" name="name" value="">
        </div>
        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="expectedClosingDate">预计成交日期</label>
            <input type="text" class="form-control time" name="expectedClosingDate" id="expectedClosingDate">
        </div>
        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="stage">阶段</label>
            <select id="stage" class="form-control" name="stage">
                <option></option>
                <c:forEach items="${stageList}" var="s">
                    <option value="${s.value}">${s.text}</option>
                </c:forEach>
            </select>
        </div>
        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="activityName">市场活动源&nbsp;&nbsp;
                <a id="actSource" data-toggle="modal" data-target="#searchActivityModal" style="text-decoration: none;">
                    <span class="glyphicon glyphicon-search"></span>
                </a>
            </label>
            <input type="text" class="form-control" id="activityName" placeholder="点击上面搜索" readonly>
        </div>
    </form>

</div>

<div id="owner" style="position: relative; left: 40px; height: 35px; top: 50px;">
    记录的所有者：<br>
    <b><span property="owner"></span></b>
</div>
<div id="operation" style="position: relative; left: 40px; height: 35px; top: 100px;">
    <input id="convertBtn" class="btn btn-primary" type="button" value="转换">
    &nbsp;&nbsp;&nbsp;&nbsp;
    <input class="btn btn-default" type="button" value="取消">
</div>
</body>
</html>