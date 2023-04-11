<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/jsp/include/commons_head.jsp" %>
    <script type="text/javascript">

        //默认情况下取消和保存按钮是隐藏的
        var cancelAndSaveBtnDefault = true;

        $(function () {
            $("#remark").focus(function () {
                if (cancelAndSaveBtnDefault) {
                    //设置remarkDiv的高度为130px
                    $("#remarkDiv").css("height", "130px");
                    //显示
                    $("#cancelAndSaveBtn").show("2000");
                    cancelAndSaveBtnDefault = false;
                }
            });

            $("#cancelBtn").click(function () {
                //显示
                $("#cancelAndSaveBtn").hide();
                //设置remarkDiv的高度为130px
                $("#remarkDiv").css("height", "90px");
                cancelAndSaveBtnDefault = true;
            });

            $("#remarkList").on("mouseover", ".remarkDiv", function(){
                $(this).children("div").children("div").show();
            });
            $("#remarkList").on("mouseout", ".remarkDiv", function(){
                $(this).children("div").children("div").hide();
            });
            $("#remarkList").on("mouseover", ".myHref", function(){
                $(this).children("span").css("color","red");
            });
            $("#remarkList").on("mouseout", ".myHref", function(){
                $(this).children("span").css("color","#E6E6E6");
            });

            var clue;

            function load() {
                $.ajax({
                    url: "/clue/get.json?id=${param.id}",
                    success: function (data) {
                        clue = data;
                        // data中只包含线索信息，不包含备注列表
                        $("text").each(function () {
                            $(this).text(data[$(this).attr("property")]);
                        });

                        loadRemarks(); //加载线索备注
                    }
                });
            }

            function loadRemarks() {

                $("div.remarkDiv").remove();// 重新加载备注，清空备注

                $.ajax({
                    url: "/clue/getRemarks.json?id=${param.id}",
                    success: function (data) {
                        $(data).each(function () {
                            // append是往元素的最后位置追加

                            var text1 = this.noteTime + " 由" + this.notePerson;

                            $("#remarkDiv").before(
                                '<div class="remarkDiv" style="height: 60px;">\
                                    <img title="zhangsan" src="/image/user-thumbnail.png" style="width: 30px; height:30px;">\
                                    <div style="position: relative; top: -40px; left: 40px;" >\
                                        <h5 id="' + this.id + '">' + this.noteContent + '</h5>\
									<font color="gray">线索</font> <font color="gray">-</font> <b>' + clue.fullName + clue.appellation + '<font color="gray">-</font>' + clue.company + '</b> <small style="color: gray;">' + text1 + '</small>\
									<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">\
										<a edit="' + this.id + '" class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>\
										&nbsp;&nbsp;&nbsp;&nbsp;\
										<a del="' + this.id + '" class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>\
									</div>\
								</div>\
							</div>'
                            )

                        });
                    }
                });
            }

            load(); // 加载线索

            function loadActivities() {

                $("#dataBody").html("");

                $.ajax({
                    url: "/clue/getActivities.json?id=${param.id}",
                    success: function (data) {
                        // data是市场活动对象的数组
                        $(data).each(function () {
                            $("#dataBody").append(
                                '<tr>\
                                    <td>' + this.name + '</td>\
                                    <td>' + this.startDate + '</td>\
                                    <td>' + this.endDate + '</td>\
                                    <td>' + this.owner + '</td>\
                                    <td>\
                                        <a href="javascript:void(0);" actid="' + this.id + '" data-toggle="modal" data-target="#unbundModal"\
                                        style="text-decoration: none;"> <span class="glyphicon glyphicon-remove"></span>解除关联</a>\
                                    </td>\
                                </tr>'
                            )
                        });
                    }
                })
            }

            loadActivities();

            function reset() {
                // 清除当前正在编辑的备注
                $("#remark").val("");
                currRemarkId = undefined;
            }

            $("#savenBtn").click(function () {
                $.ajax({
                    url: "/clue/saveRemark.do",
                    type: "post",
                    data: {
                        noteContent: $("#remark").val(),
                        clueId: "${param.id}",
                        id: currRemarkId
                    },
                    success: function (data) {
                        if(data.success) {
                            reset();
                            loadRemarks() // 重新加载备注信息
                            $.alert("操作成功！");
                        }
                    }
                })
            });
            var currRemarkId; // 用变量代替隐藏域，当前正在操作的备注id
            $("#remarkList").on("click", "a[edit]", function () {
                currRemarkId = $(this).attr("edit");
                // <h5 id="cb6d61357e184d3aae0cc629a094b159">备注内容</h5>
                var content = $("#" + currRemarkId).text();
                $("#remark").val(content);
            });

            $("#remarkList").on("click", "a[del]", function () {

                var that = this;

                $.confirm("确定删除吗？", function () {
                    $.ajax({
                        url: "/clue/delRemark.do?id=" + $(that).attr("del"),
                        type: "delete",
                        success: function (data) {
                            if(data.success) {
                                loadRemarks();
                                $.alert("操作成功！");
                            }
                        }
                    })
                });

            });

            $("#unbindBtn").click(function () {
                $.ajax({
                    // /clue/unbind/1/2
                    url: "/clue/unbind/${param.id}/" + actid,
                    type: "delete", // delete 请求，参数必须放在url中
                    success: function (data) {
                        if(data.success) {
                            //loadActivities();
                            // 为了提高效率，只操作页面元素：
                            // 移除删除的那行， has（过滤）方法是获取包含符合指定选择器的元素
                            $("tr").has("a[actid="+actid+"]").remove();
                            $("#unbundModal").modal("hide");
                        }
                    }
                });
            });

            $("body").on("click", "a[actid]", function () {
                // 将市场活动id存放到全局变量actid中，声明变量时，不使用var，相当于是全局变量
                // 相当于window.actid=xxx;
                actid = $(this).attr("actid");
            });


            /**
             * 关联市场活动需求：
             *  1. 点击关联市场活动按钮，加载出当前所有的市场活动
             *  2. 已经关联的市场活动，复选框前默认打勾
             *  3. 选择完毕之后，重新维护关联关系，当前模态窗口中展示的是最新的关系
             */

            function loadAct() {
                // 加载所有市场活动
                $("#dataBody2").html("");
                $.ajax({
                    url: "/act/getAll2.json?actName="+$("#actName").val(),
                    success: function (data) {
                        $(data).each(function () {
                            $("#dataBody2").append(
                                '<tr>\
                                    <td><input name="id" value="'+this.id+'" type="checkbox"/></td>\
                                    <td>'+this.name+'</td>\
                                    <td>'+this.startDate+'</td>\
                                    <td>'+this.endDate+'</td>\
                                    <td>'+this.owner+'</td>\
                                </tr>'
                            )
                        });

                        $("#dataBody2 input[name=id]").filter(function () {
                            // 返回true表示满足过滤条件
                            // $("a[actid="+this.value+"]") 当前关联的市场活动列表中存在的超链接
                            var size = $("a[actid="+this.value+"]").size();
                            return size > 0;
                        }).prop("checked", true);
                    }
                });
            }

            $("#bindLink").click(loadAct);

            $("#actName").keydown(function (e) {
                // 回车键
                if(e.which == 13) {
                    loadAct(); // 查询市场活动
                }
            });

            $("#selectAll").click(function () {
                $(":checkbox[name=id]").prop("checked", this.checked);
            });

            // 使用委派的方式为$(":checkbox[name=id]")绑定事件
            $("#dataBody2").on("click", ":checkbox[name=id]", function () {
                $("#selectAll").prop("checked", $(":checkbox[name=id]").size() == $(":checkbox[name=id]:checked").size());
            });

            // 关联市场活动
            $("#bindBtn").click(function () {
                // 获取选中的市场活动id
                var $cks = $("#dataBody2 :checkbox[name=id]:checked");
                var ids = $cks.map(function () {
                    return this.value;
                }).get().join(",");
                if(!ids) {
                    $.alert("请选择市场活动！");
                    return ;
                }

                $.ajax({
                    url: "/clue/bind.do?clueId=${param.id}&actIds=" + ids,
                    success: function (data) {
                        if (data.success) {
                            loadActivities(); // 重新查询关联的市场活动
                            $("#bundModal").modal('hide');
                        }
                    }
                });
            });
            
        });

    </script>

</head>
<body>

<!-- 解除关联的模态窗口 -->
<div class="modal fade" id="unbundModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 30%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">解除关联</h4>
            </div>
            <div class="modal-body">
                <p>您确定要解除该关联关系吗？</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button id="unbindBtn" type="button" class="btn btn-danger">确定</button>
            </div>
        </div>
    </div>
</div>

<!-- 关联市场活动的模态窗口 -->
<div class="modal fade" id="bundModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">关联市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <div class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <%--
                                在表单中，如果只有一个文本框，则回车键会导致表单提交
                            --%>
                            <input id="actName" type="text" class="form-control" style="width: 300px;"
                                   placeholder="请输入市场活动名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </div>
                </div>
                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td><input id="selectAll" type="checkbox"/></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                        <td></td>
                    </tr>
                    </thead>
                    <tbody id="dataBody2"></tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button id="bindBtn" type="button" class="btn btn-primary">关联</button>
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
                <h4 class="modal-title" id="myModalLabel">修改线索</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="edit-clueOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-clueOwner">
                                <option>zhangsan</option>
                                <option>lisi</option>
                                <option>wangwu</option>
                            </select>
                        </div>
                        <label for="edit-company" class="col-sm-2 control-label">公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-company" value="动力节点">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-call">
                                <option></option>
                                <option selected>先生</option>
                                <option>夫人</option>
                                <option>女士</option>
                                <option>博士</option>
                                <option>教授</option>
                            </select>
                        </div>
                        <label for="edit-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-surname" value="李四">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-job" value="CTO">
                        </div>
                        <label for="edit-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-email" value="lisi@bjpowernode.com">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-phone" value="010-84846003">
                        </div>
                        <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-website"
                                   value="http://www.bjpowernode.com">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-mphone" value="12345678901">
                        </div>
                        <label for="edit-status" class="col-sm-2 control-label">线索状态</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-status">
                                <option></option>
                                <option>试图联系</option>
                                <option>将来联系</option>
                                <option selected>已联系</option>
                                <option>虚假线索</option>
                                <option>丢失线索</option>
                                <option>未联系</option>
                                <option>需要条件</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-source" class="col-sm-2 control-label">线索来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-source">
                                <option></option>
                                <option selected>广告</option>
                                <option>推销电话</option>
                                <option>员工介绍</option>
                                <option>外部介绍</option>
                                <option>在线商场</option>
                                <option>合作伙伴</option>
                                <option>公开媒介</option>
                                <option>销售邮件</option>
                                <option>合作伙伴研讨会</option>
                                <option>内部研讨会</option>
                                <option>交易会</option>
                                <option>web下载</option>
                                <option>web调研</option>
                                <option>聊天</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe">这是一条线索的描述信息</textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-contactSummary">这个线索即将被转换</textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-nextContactTime" value="2017-05-01">
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="edit-address">北京大兴区大族企业湾</textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" data-dismiss="modal">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left"
                                                                         style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>
            <text property="fullName"></text>
            <text property="appellation"></text>
            <small>
                <text property="company"/>
            </small>
        </h3>
    </div>
    <div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
        <button type="button" class="btn btn-default"><span class="glyphicon glyphicon-envelope"></span> 发送邮件</button>
        <button type="button" class="btn btn-default" onclick="window.location.href='convert.html?id=${param.id}';"><span
                class="glyphicon glyphicon-retweet"></span> 转换
        </button>
        <button type="button" class="btn btn-default" data-toggle="modal" data-target="#editClueModal"><span
                class="glyphicon glyphicon-edit"></span> 编辑
        </button>
        <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
    </div>
</div>

<!-- 详细信息 -->
<div style="position: relative; top: -70px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>
            <text property="fullName"></text>
            <text property="appellation"></text>
        </b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>
            <text property="owner"/>
        </b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">公司</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>
            <text property="company"/>
        </b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">职位</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>
            <text property="job"/>
        </b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">邮箱</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>
            <text property="email"/>
        </b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>
            <text property="phone"/>
        </b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">公司网站</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>
            <text property="website"/>
        </b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>
            <text property="mphone"/>
        </b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">线索状态</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>
            <text property="state"/>
        </b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">线索来源</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>
            <text property="source"/>
        </b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>
            <text property="createBy"/>&nbsp;&nbsp;</b>
            <small style="font-size: 10px; color: gray;">
                <text property="createTime"/>
            </small>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>
            <text property="editBy"/>&nbsp;&nbsp;</b>
            <small style="font-size: 10px; color: gray;">
                <text property="editTime"/>
            </small>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <text property="description"/>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 80px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <text property="contactSummary"/>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 90px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>
            <text property="nextContactTime"/>
        </b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 100px;">
        <div style="width: 300px; color: gray;">详细地址</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                <text property="address"/>
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div id="remarkList" style="position: relative; top: 40px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <%--备注列表--%>

    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>
            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button id="savenBtn" type="button" class="btn btn-primary">保存</button>
            </p>
        </form>
    </div>
</div>

<!-- 市场活动 -->
<div>
    <div style="position: relative; top: 60px; left: 40px;">
        <div class="page-header">
            <h4>市场活动</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>名称</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                    <td>所有者</td>
                    <td></td>
                </tr>
                </thead>
                <tbody id="dataBody"></tbody>
            </table>
        </div>

        <div>
            <a data-toggle="modal" id="bindLink" data-target="#bundModal"
               style="text-decoration: none; cursor: pointer;">
                <span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
        </div>
    </div>
</div>


<div style="height: 200px;"></div>
</body>
</html>