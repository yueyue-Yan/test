<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/jsp/include/commons_head.jsp" %>
    <script type="text/javascript">
        jQuery(function ($) {
            //以下日历插件在FF中存在兼容问题，在IE浏览器中可以正常使用。
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

            // 发送ajax，加载市场活动列表
            function load(currentPage, rowsPerPage) {

                $("#dataBody").html("");// 清空数据

                // formJSON收集查询条件：{searchMap['name']: '悦悦', searchMap['owner']: 'yueyue'...}
                //即{map['键']: '值'，map['键']: '值'，...}
                var searchData = $("#searchForm").formJSON();

                // 分页条件[第一次调用load()，因此这里是两个undefined]
                searchData.currentPage = currentPage;
                searchData.rowsPerPage = rowsPerPage;
                console.log(searchData);
                //console.log( JSON.stringify(searchData) );

                $.ajax({
                    url: "/act/getAll.json",
                    data: searchData,
                    success: function(page) {
                        $(page.data).each(function (i) {
                            $("#dataBody").append(
                            '<tr class="'+(i%2==0?"active":"")+'">\
                                <td><input name="id" type="checkbox" value="'+this.id+'" /></td>\
                                <td><a del="'+this.id+'" style="text-decoration:none;cursor: pointer;">'+this.name+'</a></td>\
                                <td>'+this.owner+'</td>\
                                <td>'+this.startDate+'</td>\
                                <td>'+this.endDate+'</td>\
                            </tr>'
                            )
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
                console.log(data);
                //data=["Alice|六一","yueyue|悦悦"]
                $(data).each(function () {
                    $("<option>"+this+"</option>").appendTo("select[name=owner]");
                });
            });

            $("#saveBtn").click(function () {
                $.ajax({
                    url: "/act/save.do",
                    type: "post",
                    data: $("#createForm").formJSON(),
                    success: function (data) {
                        if ( data.success ) {
                            load();
                        }
                    }
                });
            });

            
            $("#createBtn").click(function () {
                // :input 包含select、input、textarea、button
                $("#createForm").find(":input").val("");

                $("select[name=owner]").val("${user.loginAct} | ${user.name}");
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
                        url: "/act/delete.do?ids="+ids,
                        type: "delete",
                        success: function (data) {
                            if (data.success) {
                                load();
                            }
                        }
                    });
                });
            });

            $("#selectAll").click(function () {
                $(":checkbox[name=id]").prop("checked", this.checked);
            });

            // 使用委派的方式为$(":checkbox[name=id]")绑定事件
            $("#dataBody").on("click", ":checkbox[name=id]", function () {
                $("#selectAll").prop("checked", $(":checkbox[name=id]").size() == $(":checkbox[name=id]:checked").size());
            });

            $("#editBtn").click(function () {
                var id = $(":checkbox[name=id]:checked:first").val();
                if (!id) {
                    $.alert("请选择编辑项！");
                    return;
                }
                // var $cks = $(":checkbox[name=id]:checked");
                // if ($cks.size() == 0) {
                //     alert("请选择要编辑的选项！");
                //     return ;
                // }
                // if ($cks.length > 1) {
                //     alert("一次只能选择一个想要编辑的选项！");
                //     return ;
                //}



                $("#editActivityModal").modal("show");

                // 注意修改表单元素的name属性
                $("#editForm").initForm("/act/get.json?id="+id);

            });

            $("#updateBtn").click(function () {
                $.ajax({
                    url: "/act/update.do",
                    type: "post",
                    data: $("#editForm").formJSON(),
                    success: function (data) {
                        if (data.success) {
                            load();
                            // 手动关闭模态窗口
                            $("#editActivityModal").modal("hide");
                        }
                    }
                });
            });

            // 查看市场活动详情
            $("#dataBody").on("click", "a[del]", function () {
                location = "/act/detailIndexView?id="+$(this).attr("del");
            });

            // 将数据导出到excel文件
            $("#exportBtn").click(function () {
                // 文件下载必须使用传统请求
                location = "/act/export.do";
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
                    url: "/act/import.do",
                    type: "post",
                    data: formData,
                    contentType: false, processData: false,// 禁用jQuery对数据的任何修改
                    success: function (data) {
                        if(data.success) {
                            $("#importActivityModal").modal("hide");
                            load();
                        }
                    }
                });
            });
        });

    </script>
</head>
<body>

<!-- 创建市场活动的模态窗口 -->
<div class="modal fade" id="createActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
            </div>
            <div class="modal-body">

                <form id="createForm" class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select name="owner" class="form-control" id="create-marketActivityOwner"></select>
                        </div>
                        <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="name" class="form-control" id="create-marketActivityName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="startDate" class="form-control time" id="create-startTime">
                        </div>
                        <label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="endDate" class="form-control time" id="create-endTime">
                        </div>
                    </div>
                    <div class="form-group">

                        <label for="create-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="cost" class="form-control" id="create-cost">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" name="description" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="saveBtn" type="button" class="btn btn-primary" data-dismiss="modal">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改市场活动的模态窗口 -->
<div class="modal fade" id="editActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
            </div>
            <div class="modal-body">
                <form id="editForm" class="form-horizontal" role="form">

                    <%--将ID存放到隐藏域，作为修改的条件--%>
                    <input name="id" type="hidden" />

                    <div class="form-group">
                        <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select name="owner" class="form-control" id="edit-marketActivityOwner"></select>
                        </div>
                        <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="name" class="form-control" id="edit-marketActivityName" value="发传单">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="startDate" class="form-control" id="edit-startTime" value="2020-10-10">
                        </div>
                        <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="endDate" class="form-control" id="edit-endTime" value="2020-10-20">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" name="cost" class="form-control" id="edit-cost" value="5,000">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" name="description" rows="3" id="edit-describe">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="updateBtn" type="button" class="btn btn-primary">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 导入市场活动的模态窗口 -->
<div class="modal fade" id="importActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
            </div>
            <div class="modal-body" style="height: 350px;">
                <div style="position: relative;top: 20px; left: 50px;">
                    请选择要上传的文件：
                    <small style="color: gray;">[仅支持.xls或.xlsx格式]</small>
                </div>
                <div style="position: relative;top: 40px; left: 50px;">
                    <input id="upFile" type="file" />
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
            <h3>市场活动列表</h3>
        </div>
    </div>
</div>
<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" id="searchForm" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" name="searchMap['name']" type="text">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" name="searchMap['owner']" type="text">
                    </div>
                </div>


                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">开始日期</div>
                        <input class="form-control time" name="searchMap['startDate']" type="text" id="startTime"/>
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">结束日期</div>
                        <input class="form-control time" name="searchMap['endDate']" type="text" id="endTime">
                    </div>
                </div>

                <button type="button" id="searchBtn" class="btn btn-default">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button id="createBtn" type="button" class="btn btn-primary" data-toggle="modal" data-target="#createActivityModal">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button id="editBtn" type="button" class="btn btn-default" data-toggle="modal"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button id="delBtn" type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
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
                    <td><input type="checkbox" id="selectAll"/></td>
                    <td>名称</td>
                    <td>所有者</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                </tr>
                </thead>
                <tbody id="dataBody"></tbody>
            </table>
        </div>

        <div id="page"></div>

    </div>
</div>
</body>
</html>