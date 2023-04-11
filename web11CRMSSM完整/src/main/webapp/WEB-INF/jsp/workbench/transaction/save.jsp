<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/jsp/include/commons_head.jsp" %>
    <script>
        jQuery(function ($) {

            // 所有者
            // 加载所有者
            $.get("/user/getAllUserName.json", function (data) {
                // data: ["工号 | zhangsan", "工号 | lisi", ...]
                $(data).each(function () {
                    $("<option>"+this+"</option>").appendTo("select[name=owner]");
                });

                // 默认选中当前登录账号
                $("select[name=owner]").val("${user.loginAct} | ${user.name}");
            });

            // 日期控件
            $("input.time:eq(0)").datetimepicker({
                minView: "month",
                language:  'zh-CN',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "bottom-left"
            });
            $("input.time:eq(1)").datetimepicker({
                minView: "month",
                language:  'zh-CN',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "top-left"
            });


            // 自动补全
            $("#create-customerName").typeahead({
                source: function (keyword, process) {
                    // keyword: 输入框中值
                    $.get("/contacts/getCustomerName.json?name=" + keyword, function (data) {
                        // ["公司名1", "公司名2", ...]
                        process(data);
                    }, "json");
                },
                delay: 500 // 输入内容500毫秒之后进行查询，如果在500毫秒内又进行了其它字符的输入，则重新计时
            });

            // 阶段和可能性的对应关系
            var stage2possiObj = {};

            // 使用forEach 遍历 Map 集合的方式
            <c:forEach items="${stage2possiMap}" var="entry">
            stage2possiObj["${entry.key}"] = ${entry.value};
            </c:forEach>

            // 选择不同的阶段，改变可能性
            $("#create-transactionStage").change(function() {
                var stage = this.value;
                $("#create-possibility").val(stage2possiObj[stage]);
            });

            function loadAct() {
                // 加载所有市场活动
                $("#actDataBody").html("");
                $.ajax({
                    url: "/act/getAll2.json?actName="+$("#actName").val(),
                    success: function (data) {
                        $(data).each(function () {
                            $("#actDataBody").append(
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

            $("#chooseAct").click(loadAct);
            $("#actName").keydown(function (event) {
                var key = event.which;
                if ( key == 13 ) {
                    loadAct();
                }
            });

            $("#contactsName").keydown(function (event) {
                var key = event.which;
                if ( key == 13 ) {
                    loadContacts();
                }
            });

            function loadContacts() {
                // 加载所有市场活动
                $("#contactsDataBody").html("");
                $.ajax({
                    url: "/contacts/getByName.json?contactsName="+$("#contactsName").val(),
                    success: function (data) {
                        $(data).each(function () {
                            $("#contactsDataBody").append(
                                '<tr>\
                                    <td><input type="radio" name="id" contactsname="'+this.fullName+'" value="'+this.id+'" /></td>\
                                <td>'+this.fullName+'</td>\
                                <td>'+this.email+'</td>\
                                <td>'+this.mphone+'</td>\
                            </tr>'
                            )
                        });
                    }
                });
            }

            $("#chooseContacts").click(loadContacts);


            $("#confirmAct").click(function () {

                // 获取选中的市场活动
                var $activity = $("#actDataBody :radio:checked");
                if ( !$activity.size() ) {
                    $.alert("请选择市场活动！");
                    return ;
                }

                // 将市场活动的名称显示在页面上
                //$("#create-activitySrc").val( $activity.parent().next().text() );
                $("#create-activitySrc").val( $activity.attr("actname") );
                // 将市场活动id存放到隐藏域中
                $("#activityId").val( $activity.val() );

                // 隐藏选择窗口
                $("#findMarketActivity").modal("hide");
            });

            $("#confirmContacts").click(function () {

                // 获取选中的联系人
                var $contacts = $("#contactsDataBody :radio:checked");
                if ( !$contacts.size() ) {
                    $.alert("请选择联系人！");
                    return ;
                }

                $("#create-contactsName").val( $contacts.attr("contactsname") );
                $("#contactsId").val( $contacts.val() );

                // 隐藏选择窗口
                $("#findContacts").modal("hide");
            });

            function checkForm(successFn) {
                var val = $.trim( $("#create-transactionName").val() );
                if (!val) {
                    $.alert("请输入名称！");
                    return ;
                }

                var val = $.trim( $("#create-expectedClosingDate").val() );
                if (!val) {
                    $.alert("请选择预计成交日期！");
                    return ;
                }

                var val = $.trim( $("#create-customerName").val() );
                if (!val) {
                    $.alert("请输入客户名称！");
                    return ;
                }

                var val = $.trim( $("#create-transactionStage").val() );
                if (!val) {
                    $.alert("请选择阶段！");
                    return ;
                }

                if( typeof (successFn) == "function") {
                    successFn();
                }

            }

            $("#saveBtn").click(function () {
                // 表单验证，验证通过之后提交表单
                checkForm(function() {
                    $.ajax({
                        url: "/tran/save.do",
                        type: "post",
                        data: $("#createForm").formJSON(),
                        success: function (data) {
                            if (data.success) {
                                $.alert("操作成功！");
                                location = "index.html";
                            }
                        }
                    })
                });


            });
        });
    </script>
</head>
<body>

<!-- 查找市场活动 -->
<div class="modal fade" id="findMarketActivity" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <div class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input id="actName" type="text" class="form-control" style="width: 300px;"
                                   placeholder="请输入市场活动名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </div>
                </div>
                <table id="activityTable3" class="table table-hover"
                       style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                    </tr>
                    </thead>
                    <tbody id="actDataBody"></tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button id="confirmAct" type="button" class="btn btn-danger">确定</button>
            </div>
        </div>
    </div>
</div>

<!-- 查找联系人 -->
<div class="modal fade" id="findContacts" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找联系人</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <div class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input id="contactsName" type="text" class="form-control" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </div>
                </div>
                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>邮箱</td>
                        <td>手机</td>
                    </tr>
                    </thead>
                    <tbody id="contactsDataBody"></tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button id="confirmContacts" type="button" class="btn btn-danger">确定</button>
            </div>
        </div>
    </div>
</div>

<div style="position:  relative; left: 30px;">
    <h3>创建交易</h3>
    <div style="position: relative; top: -40px; left: 70%;">
        <button id="saveBtn" type="button" class="btn btn-primary">保存</button>
        <button type="button" class="btn btn-default">取消</button>
    </div>
    <hr style="position: relative; top: -40px;">
</div>
<form id="createForm" class="form-horizontal" role="form" style="position: relative; top: -30px;">

    <input type="hidden" name="activityId" id="activityId" />
    <input type="hidden" name="contactsId" id="contactsId" />

    <div class="form-group">
        <label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select name="owner" class="form-control" id="create-transactionOwner"></select>
        </div>
        <label for="create-amountOfMoney" class="col-sm-2 control-label">金额</label>
        <div class="col-sm-10" style="width: 300px;">
            <input name="amountOfMoney" type="text" class="form-control" id="create-amountOfMoney">
        </div>
    </div>

    <div class="form-group">
        <label for="create-transactionName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input name="name" type="text" class="form-control" id="create-transactionName">
        </div>
        <label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input name="expectedClosingDate" type="text" class="form-control time" id="create-expectedClosingDate">
        </div>
    </div>

    <div class="form-group">
        <label for="create-customerName" class="col-sm-2 control-label">客户名称<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input name="customerName" type="text" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
        </div>
        <label for="create-transactionStage" class="col-sm-2 control-label">阶段<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select name="stage" class="form-control" id="create-transactionStage">
                <option></option>
                <c:forEach items="${stageList}" var="v">
                    <option value="${v.value}">${v.text}</option>
                </c:forEach>
            </select>
        </div>
    </div>

    <div class="form-group">
        <label for="create-transactionType" class="col-sm-2 control-label">交易类型</label>
        <div class="col-sm-10" style="width: 300px;">
            <select name="type" class="form-control" id="create-transactionType">
                <option></option>
                <c:forEach items="${transactionTypeList}" var="v">
                    <option value="${v.value}">${v.text}</option>
                </c:forEach>
            </select>
        </div>
        <label for="create-possibility" class="col-sm-2 control-label">可能性</label>
        <div class="col-sm-10" style="width: 300px;">
            <input readonly type="text" class="form-control" id="create-possibility">
        </div>
    </div>

    <div class="form-group">
        <label for="create-clueSource" class="col-sm-2 control-label">来源</label>
        <div class="col-sm-10" style="width: 300px;">
            <select name="source" class="form-control" id="create-clueSource">
                <option></option>
                <c:forEach items="${sourceList}" var="v">
                    <option value="${v.value}">${v.text}</option>
                </c:forEach>
            </select>
        </div>
        <label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;
            <a id="chooseAct" data-toggle="modal" style="cursor: pointer;" data-target="#findMarketActivity">
                <span class="glyphicon glyphicon-search"></span>
            </a></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" readonly class="form-control" id="create-activitySrc">
        </div>
    </div>

    <div class="form-group">
        <label for="create-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;
            <a id="chooseContacts" data-toggle="modal" style="cursor: pointer;" data-target="#findContacts">
                <span class="glyphicon glyphicon-search"></span></a></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" readonly class="form-control" id="create-contactsName">
        </div>
    </div>

    <div class="form-group">
        <label for="create-describe" class="col-sm-2 control-label">描述</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea name="description" class="form-control" rows="3" id="create-describe"></textarea>
        </div>
    </div>

    <div class="form-group">
        <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea name="contactSummary" class="form-control" rows="3" id="create-contactSummary"></textarea>
        </div>
    </div>

    <div class="form-group">
        <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
        <div class="col-sm-10" style="width: 300px;">
            <input name="nextContactTime" type="text" class="form-control time" id="create-nextContactTime">
        </div>
    </div>

</form>
</body>
</html>