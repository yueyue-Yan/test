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

            //定制字段
            $("#definedColumns > li").click(function (e) {
                //防止下拉菜单消失
                e.stopPropagation();
            });

            function load(currentPage, rowsPerPage) {

                $("#dataBody").html("");// 清空数据

                // 表单中的查询条件
                var searchData = $("#searchForm").formJSON();
                searchData.currentPage = currentPage;
                searchData.rowsPerPage = rowsPerPage;
                
                $.ajax({
                    url: "/customer/getPage.json",
                    data: searchData,
                    success: function (page) {
                        // 列表数据
                        $(page.data).each(function (i) {
                            $("#dataBody").append(
                            '<tr class="'+(i%2==0?"active":"")+'">\
                                <td><input name="id" value="'+this.id+'" type="checkbox"/></td>\
                                <td><a detail="'+this.id+'" style="text-decoration: none; cursor: pointer;">'+this.name+'</a></td>\
                                <td>'+this.owner+'</td>\
                                <td>'+this.phone+'</td>\
                                <td>'+this.website+'</td>\
                            </tr>'
                            );
                        });

                        // 初始化分页插件
                        $("#page").bs_pagination({
                            currentPage: page.currentPage,          // 当前页（查询条件）
                            rowsPerPage: page.rowsPerPage,          // 每页显示的记录条数（查询条件）
                            maxRowsPerPage: page.maxRowsPerPage,    // 每页最多显示的记录条数
                            totalRows: page.totalRows,              // 总记录数
                            totalPages: page.totalPages,            // 总页数
                            visiblePageLinks: page.visiblePageLinks,// 最多显示几个卡片
                            showGoToPage: true,
                            showRowsPerPage: true,
                            showRowsInfo: true,
                            showRowsDefaultInfo: true,
                            // 点击分页卡片或者是翻页按钮执行的函数
                            onChangePage: function (event, data) {
                                // 分页查询的2个关键条件：当前页和每页条数
                                load(data.currentPage, data.rowsPerPage);
                            }
                        });
                    }
                });
            }

            load();

            // 加载所有者
            $.get("/user/getAllUserName.json", function (data) {
                // data: ["工号 | zhangsan", "工号 | lisi", ...]
                $(data).each(function () {
                    $("<option>"+this+"</option>").appendTo("select[name=owner]");
                });
            });

            // 让当前登录的账号为默认的所有者
            $("#createBtn").click(function () {
                $("#create-customerOwner").val("${user.loginAct} | ${user.name}");
            });

            // successFn表单验证通过之后执行的方法
            function checkForm(successFn) {
                // 表单校验
                // 客户名称（公司名）：非空、唯一性校验
                // :visible匹配可见元素，这里的可见指的是display:none, 而不是visibility:hidden
                var name = $.trim( $("input[name=name]:visible").val() );
                if (!name) {
                    $.alert("请输入名称！");
                    return ;
                }
                // 唯一性校验
                $.ajax({
                    url: "/customer/getExists.json?name=" + name,
                    success: function (exists) {
                        if(exists) {
                            $.alert("名称已经存在！");
                            return;
                        }

                        if(typeof(successFn) == "function") {
                            successFn();
                        }
                    }
                });
            }

            // 全局ajax默认的success方法，如果方法有自己的success，则全局的会被覆盖
            $.ajaxSetup({
                success: function (data) {
                    if (data.success) {
                        load();
                        $("div[id$=Modal]").modal("hide");
                    }
                }
            });

            $("#saveBtn").click(function () {
                checkForm(function () {
                    $.ajax({
                        url: "/customer/save.do",
                        type: "post",
                        data: $("#createForm").formJSON()
                    })
                });
            });

            $("#editBtn").click(function () {
                var id = $(":checkbox[name=id]:checked:first").val();
                if(!id) {
                    $.alert("请选择要编辑的客户！");
                    return ;
                }
                // 数据回显
                $("#editForm").initForm("/customer/get.json?id="+id);
                $("#editCustomerModal").modal("show");
            });

            $("#doEditBtn").click(function () {
                checkForm(function () {
                    $.ajax({
                        url: "/customer/edit.do",
                        type: "post",
                        data: $("#editForm").formJSON()
                    })
                })
            });

            $("#selectAll").selectAll(":checkbox[name=id]");

            $("#delBtn").click(function () {
                var ids = $(":checkbox[name=id]:checked").map(function () {
                    return this.value;
                }).get().join(",");

                if (!ids) {
                    $.alert("请选择删除项！");
                    return ;
                }

                $.confirm("确定删除吗？", function () {
                    $.ajax({
                        url: "/customer/delete/" + ids,
                        type: "delete"
                    });
                });
            });

            $("body").on("click", "a[detail]", function () {
                var id = $(this).attr("detail");
                location = "detail.html?id="+id;
            });

        });

    </script>
</head>
<body>

<!-- 创建客户的模态窗口 -->
<div class="modal fade" id="createCustomerModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建客户</h4>
            </div>
            <div class="modal-body">
                <form id="createForm" class="form-horizontal" role="form">
                    <div class="form-group">
                        <label for="create-customerOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select name="owner" class="form-control" id="create-customerOwner"></select>
                        </div>
                        <label for="create-customerName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input name="name" type="text" class="form-control" id="create-customerName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input name="website" type="text" class="form-control" id="create-website">
                        </div>
                        <label for="create-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input name="phone" type="text" class="form-control" id="create-phone">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">描述</label>
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
                                <input name="nextContactTime" type="text" class="form-control time" id="create-nextContactTime">
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="create-address1" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea name="address" class="form-control" rows="1" id="create-address1"></textarea>
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

<!-- 修改客户的模态窗口 -->
<div class="modal fade" id="editCustomerModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">修改客户</h4>
            </div>
            <div class="modal-body">
                <form id="editForm" class="form-horizontal" role="form">
                    <input type="hidden" name="id" />
                    <div class="form-group">
                        <label for="edit-customerOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select name="owner" class="form-control" id="edit-customerOwner"></select>
                        </div>
                        <label for="edit-customerName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input name="name" type="text" class="form-control" id="edit-customerName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input name="website" type="text" class="form-control" id="edit-website">
                        </div>
                        <label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input name="phone" type="text" class="form-control" id="edit-phone">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea name="description" class="form-control" rows="3" id="edit-describe"></textarea>
                        </div>
                    </div>
                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea name="contactSummary" class="form-control" rows="3" id="edit-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input name="nextContactTime" type="text" class="form-control time" id="edit-nextContactTime">
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="edit-address1" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea name="address" class="form-control" rows="1" id="edit-address1"></textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="doEditBtn" type="button" class="btn btn-primary">更新</button>
            </div>
        </div>
    </div>
</div>


<!-- 导入客户的模态窗口 -->
<div class="modal fade" id="importActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel2">导入客户</h4>
            </div>
            <div class="modal-body" style="height: 350px;">
                <div style="position: relative;top: 20px; left: 50px;">
                    请选择要上传的文件：
                    <small style="color: gray;">[仅支持.xls或.xlsx格式]</small>
                </div>
                <div style="position: relative;top: 40px; left: 50px;">
                    <input type="file">
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
                <button type="button" class="btn btn-primary" data-dismiss="modal">导入</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>客户列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form id="searchForm" class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input name="searchMap['name']" class="form-control" type="text">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input name="searchMap['owner']" class="form-control" type="text">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司座机</div>
                        <input name="searchMap['phone']" class="form-control" type="text">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司网站</div>
                        <input name="searchMap['website']" class="form-control" type="text">
                    </div>
                </div>

                <button id="searchBtn" type="button" class="btn btn-default">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button id="createBtn" type="button" class="btn btn-primary" data-toggle="modal" data-target="#createCustomerModal">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button id="editBtn" type="button" class="btn btn-default" data-toggle="modal">
                    <span class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button id="delBtn" type="button" class="btn btn-danger">
                    <span class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>
            <div class="btn-group" style="position: relative; top: 18%;">
                <button id="importBtn" type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal">
                    <span class="glyphicon glyphicon-import"></span> 导入
                </button>
                <button id="exportBtn" type="button" class="btn btn-default">
                    <span class="glyphicon glyphicon-export"></span> 导出
                </button>
            </div>
        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input id="selectAll" type="checkbox"/></td>
                    <td>名称</td>
                    <td>所有者</td>
                    <td>公司座机</td>
                    <td>公司网站</td>
                </tr>
                </thead>
                <tbody id="dataBody"></tbody>
            </table>
        </div>

        <div id="page" style="position: relative;top: 30px;"></div>

    </div>
</div>
</body>
</html>