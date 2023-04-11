<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <%--include指令，将jsp引入到当前的jsp(合并)--%>
    <%@ include file="/WEB-INF/jsp/include/commons_head.jsp"%>
    <script>
        jQuery(function ($) {


            function load(currentPage, rowsPerPage) {

                $("#dataBody").html("");// 清空数据
                $.ajax({
                    url: "/dept/getAll.json",
                    // 分页的两个关键条件：当前页和每页条数
                    data: {
                        currentPage: currentPage,
                        rowsPerPage: rowsPerPage
                    },
                    success: function (page) {

                        //alert( JSON.stringify(page) )

                        /**
                         * 分页之前的data: [{部门1}, {部门2}, ...]
                         *
                         * 分页之后的data:
                         {
                            currentPage: 1,         // 当前页（查询条件）
                            rowsPerPage: 10,        // 每页显示的记录条数（查询条件）
                            maxRowsPerPage: 100,    // 每页最多显示的记录条数
                            totalPages: 31,         // 总页数
                            totalRows: 301,         // 总记录数
                            visiblePageLinks: 5,    // 显示几个卡片
                            data: [{部门1}, {部门2}, ...]
                         }
                         */
                        $(page.data).each(function (i) { // i表示当前遍历的索引
                            $("#dataBody").append(
                                '<tr class="'+(i%2==0?"active":"")+'">\
                                    <td><input name="id" type="checkbox" value="'+this.id+'" /></td>\
                                    <td>'+this.no+'</td>\
                                    <td>'+(this.name||'')+'</td>\
                                    <td>'+(this.manager||'')+'</td>\
                                    <td>'+(this.phone||'')+'</td>\
                                    <td>'+(this.description||'')+'</td>\
                                </tr>'
                            );
                        });

                        // 分页组件的初始化
                        $("#page").bs_pagination({
                            currentPage: page.currentPage,          // 当前页（查询条件）
                            rowsPerPage: page.rowsPerPage,          // 每页显示的记录条数（查询条件）
                            maxRowsPerPage: page.maxRowsPerPage,    // 每页最多显示的记录条数
                            //totalPages: page.totalPages,            // 总页数，框架会自己进行计算
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

            load(); // 首次进入页面加载

            // callback是一个函数，表单验证通过之后执行该函数
            function checkForm(callback) {

                $("#deptNoMsg").text("");

                var no = $("#deptNo").val();

                // 4为数字
                if (!/^[0-9]{4}$/.test( no )) {
                    $("#deptNoMsg").text("编号必须4位数字！不足4位在前面补0");
                    return;
                }

                // 唯一性验证，需要发送ajax请求
                $.ajax({
                    url: "/dept/getExists.json?no=" + no,
                    // async: false, // 是否异步，在实际开发中都是异步的
                    success: function (exists) {
                        if (exists) {
                            $("#deptNoMsg").text("编号已存在！");
                        } else {
                            // 表单验证通过了！
                            // 函数的调用：函数名();

                            if(typeof(callback) == "function") {
                                callback();
                            }
                        }
                    }
                });
            };

            $("#saveBtn").click(function () {
                // 如果表单验证通过，则提交
                checkForm(function() {
                    // 提交表单
                    // 收集表单数据，提交到后台
                    $.ajax({
                        url: "/dept/save.do",
                        type: "post",
                        data: {
                            no: $("#deptNo").val(),
                            name: $("#deptName").val(),
                            manager: $("#deptManager").val(),
                            description: $("#deptDesc").val(),
                            phone: $("#deptPhone").val()
                        },
                        success: function(data) {
                            // data: { success: true/false, msg: "xxx" }
                            if ( data.success ) {
                                // ajax刷新列表（目前没写）
                                //$.alert("操作成功！");

                                reload();
                            }
                        }
                    })
                });
            });

            function reload() {
                // 获取分页对象的rowsPerPage属性
                var rowsPerPage = $("#page").bs_pagination('getOption', 'rowsPerPage');
                var currentPage = $("#page").bs_pagination('getOption', 'currentPage');
                load(currentPage, rowsPerPage); // 重新加载列表
            }

            $("#deptNo").

            // 限制只能输入数字
            on("keypress", function (e) {
                // e.which 表示按下的键对应asicc码
                // String.fromCharCode将asicc码转换位对应字符
                var char = String.fromCharCode(e.which);
                // \d相当于[0-9]
                // 返回 false 表示阻止输入当前字符
                // 如果是数字，返回true，则字符可以正常键入（键盘输入），否则不键入
                return /^\d$/.test(char);
            }).
            /**
             * 格式验证，checkForm函数交给了jQuery,jQuery底层会调用该函数，
             * jQuery在调用该函数时，会将事件的句柄对象 event 传递给该函数
             * 通过 event对象，可以获得 鼠标、键盘相关的参数，例如点击是鼠标左键还是右键还是中间键，
             * 或者是当前光标在窗口中的坐标
             * 对于键盘事件来说，可以获取按下的是哪个键（ASICC码值）
             */
            on("input", checkForm);


            // 全选
            $("#selectAll").click(function () {
                $(":checkbox[name=id]").prop("checked", this.checked);
            });

            /*
                页面加载完成时，给复选框绑定点击事件，由于列表是通过
                ajax请求获得结果之后才添加到页面中的，也就是说在页面加载完成时，
                这些复选框还不存在!

                解决方案：
                    1. 将事件的绑定放在列表加载完成之后，也就是ajax中success方法的最后！
                        该方式存在的问题：每次加载列表都需要绑定事件！
                    2. 使用事件的委派机制来解决
                        事件委派：将事件绑定到目标元素的父元素上（要求父元素必须是进入页面就存在的元素）
                        当点击目标元素时，触发父元素上绑定的事件

                        委派：将事件委派给父元素
             */
            //alert($(":checkbox[name=id]").size()); // 0

            /*
                on方法中：
                    第1个参数，表示委派的事件类型
                    第2个参数，表示委派者
                    第3个参数：委派的事件


                当on方法中只有2个参数：on("click", fu)，此时不是事件的委派，而是普通方式绑定


                ":checkbox[name=id]"（事件的委派者）将click(委派的事件类型)事件委派给了"#dataBody"，
                因为"#dataBody"在页面一开始的时候就存在
             */
            $("#dataBody").on("click", ":checkbox[name=id]", function () {
                var checked = $(":checkbox[name=id]").size() == $(":checkbox[name=id]:checked").size();
                $("#selectAll").prop("checked", checked);
            });

            $("#deleteBtn").click(function () {
                // 获取选中的复选框
                var $cks = $(":checkbox[name=id]:checked");
                // 判断是否选择
                if ($cks.size() == 0) {
                    $.alert("请选择删除项！");
                    return ;
                }
                
                // 给出确认
                $.confirm("确定删除吗？", function () {
                    // 提取id
                    // map方法：对数组中的元素进行处理，转换成其它数组
                    // get方法是将jQuery对象转换为DOM对象
                    var ids = $cks.map(function() {
                        return this.value;
                    }).get().join(",");

                    $.ajax({
                        url: "/dept/delete.do?ids="+ids,
                        success: function (data) {
                            //alert(JSON.stringify(data));
                            if (data.success) {
                                //$.alert("删除成功！");

                                reload(); // 重新加载列表
                            }
                        }
                    })
                });

            });

            $("#editBtn").click(function () {
                var id = $(":checkbox[name=id]:checked:first").val();
                if(!id) {
                    $.alert("请选择编辑项！");
                    return false; // 阻止弹出模态窗口
                }

                // 使用要求：表单元素的name属性和返回的js对象中的key要一致
                $("#editDeptForm").initForm("/dept/get.json?id=" + id);

            });
            
            
            $("#saveBtn2").click(function () {
                $.ajax({
                    url: "/dept/update.do",
                    type: "post",
                    // formJSON 方法将表单数据封装成对象
                    data: $("#editDeptForm").formJSON(),
                    /*
                        返回的数据类型，没有默认值，数据类型根据响应头中从Content-Type进行处理
                        如果后台正常返回，则Content-Type为application/json，jQuery就会将
                        响应结果（json字符串）转换成js对象
                     */
                    //dataType: "text",
                    success: function (data) {
                        if ( data.success ) {
                            reload(); //  重新加载数据
                        }
                    }
                })
            });


        });
    </script>
</head>
<body>

<!-- 创建部门的模态窗口 -->
<div class="modal" id="createDeptModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title"><span class="glyphicon glyphicon-plus"></span> 新增部门</h4>
            </div>
            <div class="modal-body">
                <form id="createDeptForm" class="form-horizontal" role="form">
                    <div class="form-group">
                        <label for="deptNo" class="col-sm-2 control-label">编号<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" maxlength="4" class="form-control" name="no" id="deptNo" style="width: 200%;"
                                   placeholder="编号为四位数字，不能为空，具有唯一性">
                            <div id="deptNoMsg" style="color:red;"></div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="deptName" class="col-sm-2 control-label">名称</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" name="name" id="deptName" style="width: 200%;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="deptManager" class="col-sm-2 control-label">负责人</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" name="manager" id="deptManager" style="width: 200%;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="deptPhone" class="col-sm-2 control-label">电话</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" name="phone" id="deptPhone" style="width: 200%;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="deptDesc" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 55%;">
                            <textarea class="form-control" rows="3" name="description" id="deptDesc"></textarea>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <%--
                    data-dismiss: 关闭指定的组件，如果是模态窗口，则表示当前显示的模态窗口
                --%>
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="saveBtn" type="button" class="btn btn-primary" data-dismiss="modal">保存</button>
            </div>
        </div>
    </div>
</div>


<!-- 编辑部门的模态窗口 -->
<div class="modal" id="editDeptModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title"><span class="glyphicon glyphicon-plus"></span> 编辑部门</h4>
            </div>
            <div class="modal-body">
                <form id="editDeptForm" class="form-horizontal" role="form">
                    <input type="hidden" name="id" />
                    <div class="form-group">
                        <label for="deptNo" class="col-sm-2 control-label">编号<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" maxlength="4" readonly class="form-control" name="no" style="width: 200%;"
                                   placeholder="编号为四位数字，不能为空，具有唯一性">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="deptName" class="col-sm-2 control-label">名称</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" name="name" style="width: 200%;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="deptManager" class="col-sm-2 control-label">负责人</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" name="manager" style="width: 200%;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="deptPhone" class="col-sm-2 control-label">电话</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" name="phone" style="width: 200%;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="deptDesc" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 55%;">
                            <textarea class="form-control" rows="3" name="description"></textarea>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <%--
                    data-dismiss: 关闭指定的组件，如果是模态窗口，则表示当前显示的模态窗口
                --%>
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="saveBtn2" type="button" class="btn btn-primary" data-dismiss="modal">保存</button>
            </div>
        </div>
    </div>
</div>


<!-- 我的资料 -->
<div class="modal fade" id="myInformation" role="dialog">
    <div class="modal-dialog" role="document" style="width: 30%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">我的资料</h4>
            </div>
            <div class="modal-body">
                <div style="position: relative; left: 40px;">
                    姓名：<b>张三</b><br><br>
                    登录帐号：<b>zhangsan</b><br><br>
                    组织机构：<b>1005，市场部，二级部门</b><br><br>
                    邮箱：<b>zhangsan@bjpowernode.com</b><br><br>
                    失效时间：<b>2017-02-14 10:10:10</b><br><br>
                    允许访问IP：<b>127.0.0.1,192.168.100.2</b>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改密码的模态窗口 -->
<div class="modal fade" id="editPwdModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 70%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">修改密码</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <div class="form-group">
                        <label for="oldPwd" class="col-sm-2 control-label">原密码</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="oldPwd" style="width: 200%;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="newPwd" class="col-sm-2 control-label">新密码</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="newPwd" style="width: 200%;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="confirmPwd" class="col-sm-2 control-label">确认密码</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="confirmPwd" style="width: 200%;">
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" data-dismiss="modal"
                        onclick="window.location.href='../login.html';">更新
                </button>
            </div>
        </div>
    </div>
</div>

<!-- 退出系统的模态窗口 -->
<div class="modal fade" id="exitModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 30%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">离开</h4>
            </div>
            <div class="modal-body">
                <p>您确定要退出系统吗？</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" data-dismiss="modal"
                        onclick="window.location.href='/user/logout.do';">确定
                </button>
            </div>
        </div>
    </div>
</div>

<!-- 顶部 -->
<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
    <div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">
        CRM &nbsp;<span style="font-size: 12px;">&copy;2017&nbsp;动力节点</span></div>
    <div style="position: absolute; top: 15px; right: 15px;">
        <ul>
            <li class="dropdown user-dropdown">
                <a href="javascript:void(0)" style="text-decoration: none; color: white;" class="dropdown-toggle"
                   data-toggle="dropdown">
                    <span class="glyphicon glyphicon-user"></span> zhangsan <span class="caret"></span>
                </a>
                <ul class="dropdown-menu">
                    <li><a href="/workbench/index.html"><span class="glyphicon glyphicon-home"></span> 工作台</a></li>
                    <li><a href="/settings/index.html"><span class="glyphicon glyphicon-wrench"></span> 系统设置</a></li>
                    <li><a href="javascript:void(0)" data-toggle="modal" data-target="#myInformation"><span
                            class="glyphicon glyphicon-file"></span> 我的资料</a></li>
                    <li><a href="javascript:void(0)" data-toggle="modal" data-target="#editPwdModal"><span
                            class="glyphicon glyphicon-edit"></span> 修改密码</a></li>
                    <li><a href="javascript:void(0);" data-toggle="modal" data-target="#exitModal"><span
                            class="glyphicon glyphicon-off"></span> 退出</a></li>
                </ul>
            </li>
        </ul>
    </div>
</div>


<div style="width: 95%">
    <div>
        <div style="position: relative; left: 30px; top: -10px;">
            <div class="page-header">
                <h3>部门列表</h3>
            </div>
        </div>
    </div>
    <div class="btn-toolbar" role="toolbar"
         style="background-color: #F7F7F7; height: 50px; position: relative;left: 30px; top:-30px;">
        <div class="btn-group" style="position: relative; top: 18%;">
            <%--
                data-toggle: 表示操作的组件是modal
                data-target: 组件的选择器，一般为id选择器
            --%>
            <button id="createBtn" type="button" class="btn btn-primary" data-toggle="modal" data-target="#createDeptModal">
                <span class="glyphicon glyphicon-plus"></span> 创建
            </button>
            <button id="editBtn" type="button" class="btn btn-default" data-toggle="modal" data-target="#editDeptModal">
                <span class="glyphicon glyphicon-edit"></span> 编辑
            </button>
            <button id="deleteBtn" type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
        </div>
    </div>
    <div style="position: relative; left: 30px; top: -10px;">
        <table class="table table-hover">
            <thead>
            <tr style="color: #B3B3B3;">
                <td><input id="selectAll" type="checkbox"/></td>
                <td>编号</td>
                <td>名称</td>
                <td>负责人</td>
                <td>电话</td>
                <td>描述</td>
            </tr>
            </thead>
            <tbody id="dataBody"></tbody>
        </table>
    </div>

    <div id="page"></div>

</div>

</body>
</html>