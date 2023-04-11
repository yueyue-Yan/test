<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/jsp/include/commons_head.jsp" %>
    <script type="text/javascript">

        jQuery(function ($) {

            //定制字段
            $("#definedColumns > li").click(function (e) {
                //防止下拉菜单消失
                e.stopPropagation();
            });

            $("input.time").datetimepicker({
                minView: "hour",
                language:  'zh-CN',
                format: 'yyyy-mm-dd hh:mm:ss',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "top-left"
            });

            // 查看市场活动详情
            $("#dataBody").on("click", "a[del]", function () {
                location = "/workbench/clue/detail.html?id="+$(this).attr("del");
            });

            // 发送ajax，加载市场活动列表
            function load(currentPage, rowsPerPage) {

                $("#dataBody").html("");// 清空数据

                // 查询条件：表单元素要有name属性
                var searchData = $("#searchForm").formJSON();

                // 分页条件
                searchData.currentPage = currentPage;
                searchData.rowsPerPage = rowsPerPage;

                //console.log( JSON.stringify(searchData) );

                $.ajax({
                    url: "/clue/getAll.json",
                    data: searchData,
                    success: function(page) {
                        $(page.data).each(function (i) {
                            $("#dataBody").append(
                                '<tr class="'+(i%2==0?"active":"")+'">\
                                    <td><input name="id" value="'+this.id+'" type="checkbox"/></td>\
                                    <td><a del="'+this.id+'" style="text-decoration: none; cursor: pointer;">'+this.fullName+this.appellation+'</a></td>\
                                    <td>'+this.company+'</td>\
                                    <td>'+this.phone+'</td>\
                                    <td>'+this.mphone+'</td>\
                                    <td>'+this.source+'</td>\
                                    <td>'+this.owner+'</td>\
                                    <td>'+this.state+'</td>\
                                </tr>'
                            )
                        });

                        // 初始化分页插件
                        $("#page").bs_pagination({
                            currentPage: page.currentPage,          // 当前页（查询条件）
                            rowsPerPage: page.rowsPerPage,          // 每页显示的记录条数（查询条件）
                            maxRowsPerPage: page.maxRowsPerPage,    // 每页最多显示的记录条数
                            totalRows: page.totalRows,              // 总记录数
                            visiblePageLinks: page.visiblePageLinks,// 最多显示几个卡片
                            showGoToPage: true,
                            showRowsPerPage: true,
                            showRowsInfo: true,
                            showRowsDefaultInfo: true,
                            // 点击分页卡片或者是翻页按钮执行的函数
                            onChangePage: function (event, data) {

                                // 分页查询的2个关键条件：当前页和每页条数
                                //alert("当前页是"+data.currentPage);
                                //alert("每页条数是"+data.rowsPerPage);
                                load(data.currentPage, data.rowsPerPage);
                            }
                        });
                    }
                });

            }

            load();

            $("#searchBtn").click(function () {
                load();
            });


            // 加载所有者
            $.get("/user/getAllUserName.json", function (data) {
                // data: ["工号 | zhangsan", "工号 | lisi", ...]
                $(data).each(function () {
                    $("<option>"+this+"</option>").appendTo("select[name=owner]");
                });
            });

            $("#saveBtn").click(function () {
                // 表单验证...
                $.ajax({
                    url: "/clue/save.do",
                    type: "post",
                    data: $("#createClueForm").formJSON(),
                    success: function (data) {
                        if (data.success) {
                            load();
                            $("#createClueModal").modal("hide");
                        }
                    }
                })
            });


            $("#updateBtn").click(function () {
                var id = $(":checkbox[name=id]:checked:first").val();
                if (!id) {
                    $.alert("请选择删除项！");
                    return ;
                }

                // 数据回显
                $("#editClueForm").initForm("/clue/get.json?id="+id);
                $("#editClueModal").modal("show");
            });

            // 全局ajax默认的success方法，如果方法有自己的success，则全局的会被覆盖
            $.ajaxSetup({
                success: function (data) {
                    if (data.success) {
                        load();
                        $("div[id$=Modal]").modal("hide");
                    }
                }
            });

            $("#editBtn").click(function () {
                $.ajax({
                    url: "/clue/update.do",
                    type: "post",
                    data: $("#editClueForm").formJSON()
                })
            });


            $("#selectAll").click(function () {
                $(":checkbox[name=id]").prop("checked", this.checked);
            });

            // 使用委派的方式为$(":checkbox[name=id]")绑定事件
            $("#dataBody").on("click", ":checkbox[name=id]", function () {
                $("#selectAll").prop("checked", $(":checkbox[name=id]").size() == $(":checkbox[name=id]:checked").size());
            });


            $("#delBtn").click(function () {
                var $cks = $(":checkbox[name=id]:checked");
                if ($cks.size() == 0) {
                    $.alert("请选择删除项！");
                    return ;
                }

                $.confirm("确定删除吗？", function () {
                    /*
                        map方法是将原有数组转换为其它数组
                        该方法返回的是jQuery的数组对象
                        可以调用get方法将其转换为DOM对象（原生数组）
                     */
                    var ids = $cks.map(function () {
                        return this.value;
                    }).get().join(",");

                    $.ajax({
                        url: "/clue/delete.do?ids="+ids,
                        type: "delete"
                    });
                });
            });


            // 将数据导出到excel文件
            $("#exportBtn").click(function () {
                // 文件下载必须使用传统请求
                location = "/clue/export.do";
            });

            $("#doImportBtn").click(function () {
                var files = $("#upFile")[0].files;
                if ( files.length == 0 ) {
                    $.alert("请选择文件！");
                    return ;
                }

                var file = files[0];
                var filename = file.name;
                if( !/\.xlsx?$/i.test(filename) ) {
                    $.alert("请选择Excel文件！");
                    return ;
                }

                // 有文件上传时，需要使用formData
                var formData = new FormData();
                formData.append("file", file);

                $.ajax({
                    url: "/clue/import.do",
                    type: "post",
                    data: formData,
                    contentType: false, processData: false// 禁用jQuery对数据的任何修改
                });
            });

        });

    </script>
</head>
<body>

<!-- 创建线索的模态窗口 -->
<div class="modal fade" id="createClueModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">创建线索</h4>
            </div>
            <div class="modal-body">
                <form id="createClueForm" class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="create-clueOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select name="owner" class="form-control" id="create-clueOwner">
                            </select>
                        </div>
                        <label for="create-company" class="col-sm-2 control-label">公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="company" class="form-control" id="create-company">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select name="appellation" class="form-control" id="create-call">
                                <option></option>
                                <c:forEach items="${appellationList}" var="a">
                                    <option value="${a.value}">${a.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="fullName" class="form-control" id="create-surname">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="job" class="form-control" id="create-job">
                        </div>
                        <label for="create-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="email" class="form-control" id="create-email">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="phone" class="form-control" id="create-phone">
                        </div>
                        <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="website" class="form-control" id="create-website">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="mphone" class="form-control" id="create-mphone">
                        </div>
                        <label for="create-status" class="col-sm-2 control-label">线索状态</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select name="state" class="form-control" id="create-status">
                                <option></option>
                                <c:forEach items="${clueStateList}" var="a">
                                    <option value="${a.value}">${a.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-source" class="col-sm-2 control-label">线索来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select name="source" class="form-control" id="create-source">
                                <option></option>
                                <c:forEach items="${sourceList}" var="a">
                                    <option value="${a.value}">${a.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>


                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">线索描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea name="description" class="form-control" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea name="contactSummary" class="form-control" rows="3" id="create-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" name="nextContactTime" class="form-control time" id="create-nextContactTime">
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea name="address" class="form-control" rows="1" id="create-address"></textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="saveBtn" type="button" class="btn btn-primary">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改线索的模态窗口 -->
<div class="modal fade" id="editClueModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">修改线索</h4>
            </div>
            <div class="modal-body">
                <form id="editClueForm" class="form-horizontal" role="form">
                    <input type="hidden" name="id" />
                    <div class="form-group">
                        <label for="create-clueOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select name="owner" class="form-control" id="create-clueOwner2">
                            </select>
                        </div>
                        <label for="create-company" class="col-sm-2 control-label">公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="company" class="form-control" id="create-company2">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select name="appellation" class="form-control" id="create-call2">
                                <option></option>
                                <c:forEach items="${appellationList}" var="a">
                                    <option value="${a.value}">${a.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="fullName" class="form-control" id="create-surname2">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="job" class="form-control" id="create-job2">
                        </div>
                        <label for="create-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="email" class="form-control" id="create-email2">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="phone" class="form-control" id="create-phone2">
                        </div>
                        <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="website" class="form-control" id="create-website2">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="mphone" class="form-control" id="create-mphone2">
                        </div>
                        <label for="create-status" class="col-sm-2 control-label">线索状态</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select name="state" class="form-control" id="create-status2">
                                <option></option>
                                <c:forEach items="${clueStateList}" var="a">
                                    <option value="${a.value}">${a.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-source" class="col-sm-2 control-label">线索来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select name="source" class="form-control" id="create-source2">
                                <option></option>
                                <c:forEach items="${sourceList}" var="a">
                                    <option value="${a.value}">${a.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>


                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">线索描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea name="description" class="form-control" rows="3" id="create-describe2"></textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea name="contactSummary" class="form-control" rows="3" id="creat2e-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" name="nextContactTime" class="form-control time" id="crea2te-nextContactTime">
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea name="address" class="form-control" rows="1" id="creat2e-address"></textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="editBtn" type="button" class="btn btn-primary">更新</button>
            </div>
        </div>
    </div>
</div>


<!-- 导入线索的模态窗口 -->
<div class="modal fade" id="importClueModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">导入线索</h4>
            </div>
            <div class="modal-body" style="height: 350px;">
                <div style="position: relative;top: 20px; left: 50px;">
                    请选择要上传的文件：
                    <small style="color: gray;">[仅支持.xls或.xlsx格式]</small>
                </div>
                <div style="position: relative;top: 40px; left: 50px;">
                    <input id="upFile" type="file">
                </div>
                <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;">
                    <h3>重要提示</h3>
                    <ul>
                        <li>给定文件的第一行将视为字段名。</li>
                        <li>请确认您的文件大小不超过5MB。</li>
                        <li>从XLS/XLSX文件中导入全部重复记录之前都会被忽略。</li>
                        <li>复选框值应该是1或者0。</li>
                        <li>日期值必须为MM/dd/yyyy格式。任何其它格式的日期都将被忽略。</li>
                        <li>日期时间必须符合MM/dd/yyyy hh:mm:ss的格式，其它格式的日期时间将被忽略。</li>
                        <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                        <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                    </ul>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="doImportBtn" type="button" class="btn btn-primary">导入</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>线索列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form id="searchForm" class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">联系人名称</div>
                        <input class="form-control" name="searchMap['fullName']" type="text">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司</div>
                        <input class="form-control" name="searchMap['company']" type="text">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司座机</div>
                        <input class="form-control" name="searchMap['phone']" type="text">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">线索来源</div>
                        <select name="searchMap['source']" class="form-control">
                            <option></option>
                            <c:forEach items="${sourceList}" var="v">
                                <option value="${v.value}">${v.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <br>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" name="searchMap['owner']" type="text">
                    </div>
                </div>


                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">手机</div>
                        <input class="form-control" name="searchMap['mphone']" type="text">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">线索状态</div>
                        <select name="searchMap['state']" class="form-control">
                            <option></option>
                            <c:forEach items="${clueStateList}" var="v">
                                <option value="${v.value}">${v.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <button id="searchBtn" type="button" class="btn btn-default">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#createClueModal"><span
                        class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button id="updateBtn" type="button" class="btn btn-default" data-toggle="modal"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button id="delBtn" type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
            </div>
            <div class="btn-group" style="position: relative; top: 18%;">
                <button id="importBtn" type="button" class="btn btn-default" data-toggle="modal" data-target="#importClueModal"><span
                        class="glyphicon glyphicon-import"></span> 导入
                </button>
                <button id="exportBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 导出
                </button>
            </div>

        </div>
        <div style="position: relative;top: 50px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input id="selectAll" type="checkbox"/></td>
                    <td>名称</td>
                    <td>公司</td>
                    <td>公司座机</td>
                    <td>手机</td>
                    <td>线索来源</td>
                    <td>所有者</td>
                    <td>线索状态</td>
                </tr>
                </thead>
                <tbody id="dataBody">
                <%--<tr>
                    <td><input type="checkbox"/></td>
                    <td><a style="text-decoration: none; cursor: pointer;"
                           onclick="window.location.href='detail.html';">李四先生</a></td>
                    <td>动力节点</td>
                    <td>010-84846003</td>
                    <td>12345678901</td>
                    <td>广告</td>
                    <td>zhangsan</td>
                    <td>已联系</td>
                </tr>--%>

                </tbody>
            </table>
        </div>

        <div id="page" style="position: relative;top: 60px;"></div>

    </div>

</div>
</body>
</html>