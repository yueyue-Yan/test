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

            function load(currentPage, rowsPerPage) {

                $("#dataBody").html("");

                // 查询条件
                var searchData = $("#searchForm").formJSON();
                searchData.currentPage = currentPage;
                searchData.rowsPerPage = rowsPerPage;

                // 发送查询请求
                $.ajax({
                    url: "/tran/getPage.json",
                    data: searchData,
                    success: function (page) {
                        $(page.data).each(function (i) {
                            var tr = '\
                            <tr class="{{className}}">\
                                <td><input name="id" value="{{id}}" type="checkbox"/></td>\
                                <td><a detail="{{id}}" style="text-decoration: none; cursor: pointer;">{{name}}</a></td>\
                                <td>{{customerName}}</td>\
                                <td>{{stage}}</td>\
                                <td>{{type}}</td>\
                                <td>{{owner}}</td>\
                                <td>{{source}}</td>\
                                <td>{{contactsName}}</td>\
                            </tr>';

                            // 正则表达式从入门到精通
                            var className = i % 2 == 0 ? "active" : "";
                            tr = tr.replace("{{className}}", className);

                            // 需要替换的属性数组
                            // arr: ["id","customerName", "stage", ...]
                            var arr = $( tr.match(/{{.+?}}/g) ).map(function() {
                                // {{id}} ===> id
                                return this.replace(/[{}]/g, "");
                            }).get();

                            for ( var i = 0; i < arr.length; i++ ) {
                                // "id"
                                tr = tr.replace("{{" + arr[i] + "}}", this[ arr[i] ] || "");
                            }

                            /*for( var key in this ) {
                                var reg = eval("/{{" + key + "}}/g");
                                //var reg = new RegExp("{{" + key + "}}","g"); // 底层是 eval

                                tr = tr.replace(reg, this[key]);
                            }*/

                            $("#dataBody").append(tr);
                        });

                        // 初始化分页组件
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
                })

            }

            load();

            $("#searchBtn").click(function () {
                load();
            });

            $("#createBtn").click(function () {
                location = "save.html";
            });

            $("#dataBody").on("click", "a[detail]", function () {
                // alert( $(this).attr("detail") );
                location = "detail.html?id=" + $(this).attr("detail");
            });
        });

    </script>
</head>
<body>

<!-- 导入交易的模态窗口 -->
<div class="modal fade" id="importClueModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">导入交易</h4>
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
            <h3>交易列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form id="searchForm" class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input name="searchMap['owner']" class="form-control" type="text">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input name="searchMap['name']" class="form-control" type="text">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">客户名称</div>
                        <input name="searchMap['customerName']" class="form-control" type="text">
                    </div>
                </div>

                <br>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">阶段</div>
                        <select name="searchMap['stage']" class="form-control">
                            <option></option>
                            <c:forEach items="${stageList}" var="v">
                                <option value="${v.value}">${v.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">交易类型</div>
                        <select name="searchMap['type']" class="form-control">
                            <option></option>
                            <c:forEach items="${transactionTypeList}" var="v">
                                <option value="${v.value}">${v.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">来源</div>
                        <select name="searchMap['source']" class="form-control" id="create-clueSource">
                            <option></option>
                            <c:forEach items="${sourceList}" var="v">
                                <option value="${v.value}">${v.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">联系人名称</div>
                        <input name="searchMap['contactsName']" class="form-control" type="text">
                    </div>
                </div>

                <button id="searchBtn" type="button" class="btn btn-default">查询</button>
            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button id="createBtn" type="button" class="btn btn-primary"><span
                        class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button id="updateBtn" type="button" class="btn btn-default"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button id="deleteBtn" type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
            </div>
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importClueModal"><span
                        class="glyphicon glyphicon-import"></span> 导入
                </button>
                <button type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 导出
                </button>
            </div>

        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox"/></td>
                    <td>名称</td>
                    <td>客户名称</td>
                    <td>阶段</td>
                    <td>类型</td>
                    <td>所有者</td>
                    <td>来源</td>
                    <td>联系人名称</td>
                </tr>
                </thead>
                <tbody id="dataBody"></tbody>
            </table>
        </div>

        <div id="page" style="position: relative;top: 20px;"></div>

    </div>

</div>
</body>
</html>