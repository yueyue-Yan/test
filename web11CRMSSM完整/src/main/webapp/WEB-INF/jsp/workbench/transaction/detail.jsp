<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/jsp/include/commons_head.jsp" %>
    <style type="text/css">
        .mystage {
            font-size: 20px;
            vertical-align: middle;
            cursor: pointer;
        }

        .closingDate {
            font-size: 15px;
            cursor: pointer;
            vertical-align: middle;
        }

        .cgreen {color: #90F790;}
        .cred {color: red;}

    </style>

    <script type="text/javascript">

        //默认情况下取消和保存按钮是隐藏的
        var cancelAndSaveBtnDefault = true;

        jQuery(function ($) {
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

            $(".remarkDiv").mouseover(function () {
                $(this).children("div").children("div").show();
            });

            $(".remarkDiv").mouseout(function () {
                $(this).children("div").children("div").hide();
            });

            $(".myHref").mouseover(function () {
                $(this).children("span").css("color", "red");
            });

            $(".myHref").mouseout(function () {
                $(this).children("span").css("color", "#E6E6E6");
            });

            // 声明变量时不使用var关键字，则是全局变量
            // 将java中的Map集合，处理成js对象
            stage2possiObj = {};
            <c:forEach items="${stage2possiMap}" var="entry">
            stage2possiObj["${entry.key}"] = ${entry.value};
            </c:forEach>

            // 加载交易信息
            $.ajax({
                url: "/tran/get.json?id=${param.id}",
                success: function (tran) {
                    window.tran = tran; // 将当前交易对象保存为全局变量
                    //alert( JSON.stringify(tran) );

                    $("[text]").text(function() {
                        var property = $(this).attr("text");

                        if ( property == "possibility" ) {
                            return stage2possiObj[tran.stage];
                        }

                        if ( property == "amountOfMoney" ) {
                            // 123456789.123123 ===>  123,456,789.123123
                            return tran.amountOfMoney.replace(/\B(?<!(\.\d+))(?=(\d{3})+\b)/g, ",");
                        }

                        //console.log("tran." + property);
                        // eval函数会把字符串当做JavaScript解析
                        return eval("tran." + property);
                    });

                    // 初始化阶段图标
                    initIcons();
                }
            });

            /* 阶段状态
                黑圈(未完成)：glyphicon mystage glyphicon-record
                绿色水滴（当前进行中）：glyphicon mystage glyphicon-map-marker cgreen
                绿色圆圈（已经完成）：glyphicon mystage glyphicon-ok-circle cgreen
                以上3种情况可能性都不是0

                黑X（交易失败）：glyphicon mystage glyphicon-remove
                红X（以该形式失败）：glyphicon mystage glyphicon-remove cred
                以上2种情况可能都是0

                当前阶段：进入页面之后，使用ajax加载了当前的交易信息，当前阶段在js变量中保存着：tran.stage
                当前阶段对应的可能性：stage2possiObj[tran.stage]

            */

            // 将java中的阶段集合，处理成js的数组
            var stageArr = [];
            <c:forEach items="${stageList}" var="v">
            stageArr.push({value: "${v.value}", text: "${v.text}"})
            </c:forEach>
            //alert( JSON.stringify(stageArr) );

            function initIcons() {
                $("#icons").html("");
                <%--<c:forEach items="${stageList}" var="v">--%>
                for (var i = 0; i < stageArr.length; i++) {
                    var curr = stageArr[i];
                    var icon = "";
                    /*
                        可能性不是0:
                            可能性小于当前阶段的可能性：绿圈
                            可能性等于当前阶段的可能性：水滴
                            可能性大于当前阶段的可能性：黑圈
                     */
                    if ( stage2possiObj[curr.value] != 0 ) {
                        // 可能性小于当前阶段的可能性：绿圈
                        if (stage2possiObj[tran.stage] > stage2possiObj[curr.value]) {
                            icon = "glyphicon-ok-circle cgreen";
                        }
                        // 可能性等于当前阶段的可能性：水滴
                        else if (stage2possiObj[tran.stage] == stage2possiObj[curr.value]) {
                            icon = "glyphicon-map-marker cgreen";
                        }
                        // 可能性大于当前阶段的可能性：黑圈
                        else {
                            icon = "glyphicon-record";
                        }
                    }
                    // 可能性为0
                    else {
                        // 当前阶段和遍历中的阶段一致
                        if ( curr.value == tran.stage ) {
                            icon = "glyphicon-remove cred";
                        } else {
                            icon = "glyphicon-remove";
                        }
                    }

                    $("#icons").append('<span class="glyphicon mystage ' + icon + '" data-toggle="popover"\
                    data-placement="bottom" data-stage="'+curr.value+'" data-content="'+curr.text+'"></span> ----------- ');
                }

                <%--</c:forEach>--%>


                //阶段提示框
                $("span.mystage").popover({
                    trigger: 'manual',
                    placement: 'bottom',
                    html: 'true',
                    animation: false
                }).on("mouseenter", function () {
                    var _this = this;
                    $(this).popover("show");
                    $(this).siblings(".popover").on("mouseleave", function () {
                        $(_this).popover('hide');
                    });
                }).on("mouseleave", function () {
                    var _this = this;
                    setTimeout(function () {
                        if (!$(".popover:hover").length) {
                            $(_this).popover("hide")
                        }
                    }, 100);
                }).on("click", function () {
                    // 更新交易阶段get\post\delete\put
                    var that = this;
                    $.ajax({
                        url: "/tran/changeStage.do",
                        type: "post",
                        data: {
                            id: "${param.id}",
                            //stage: $(this).attr("data-stage"),
                            stage: $(this).data("stage") // 获取标签上的data-stage属性
                        },
                        success: function (data) {
                            if ( data.success ) {
                                // 阶段图标重新初始化
                                tran.stage = $(that).data("stage");// 先改变当前交易的阶段，然后再重新初始化图标
                                initIcons();

                                // 交易阶段
                                $("[text=stage]").text(tran.stage);

                                // 可能性
                                $("[text=possibility]").text( stage2possiObj[tran.stage] );

                                /*
                                  修改人（当前用户）和修改时间
                                  修改时间能否用js来获取？
                                  js获取的时间是客户端时间，客户端的时间是可以修改的，因此不能使用
                                  必须使用服务器时间，需要后台返回这个时间
                                */
                                $("[text=editBy]").text(data.editBy);
                                $("[text=editTime]").text(data.editTime);

                                // 重新加载交易历史
                                loadHistory();
                            }
                        }
                    })
                });

            }




            // 加载交易备注（略）


            // 加载交易历史
            function loadHistory() {
                $("#dataBody").html("");
                $.ajax({
                    url: "/tran/getHistory.json?id=${param.id}",
                    success: function (data) {
                        $(data).each(function () {
                            $("#dataBody").append('\
                            <tr>\
                                <td>'+this.stage+'</td>\
                                <td>'+this.amountOfMoney.replace(/\B(?<!(\.\d+))(?=(\d{3})+\b)/g, ",")+'</td>\
                                <td>'+stage2possiObj[this.stage]+'</td>\
                                <td>'+this.expectedClosingDate+'</td>\
                                <td>'+this.editTime+'</td>\
                                <td>'+this.editBy+'</td>\
                            </tr>'
                            )
                        });
                    }
                });
            }
            loadHistory();



        });


    </script>

</head>
<body>

<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.history.back();">
        <span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span>
    </a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3><span text="name"></span>
            <small>￥<span text="amountOfMoney"></span></small>
        </h3>
    </div>
    <div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
        <button type="button" class="btn btn-default" onclick="window.location.href='edit.html';">
            <span class="glyphicon glyphicon-edit"></span> 编辑
        </button>
        <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
    </div>
</div>


<div style="position: relative; left: 40px; top: -50px;">
    阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <span id="icons"></span>
    <span class="closingDate" text="expectedClosingDate"></span>
</div>

<!-- 详细信息 -->
<div id="tranInfo" style="position: relative; top: 0px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b text="owner"></b>&nbsp;</div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b text="amountOfMoney"></b>&nbsp;</div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b text="name"></b>&nbsp;</div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b text="expectedClosingDate"></b>&nbsp;</div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">客户名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b text="customer.name"></b>&nbsp;</div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b text="stage"></b>&nbsp;</div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">类型</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b text="type"></b>&nbsp;</div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b text="possibility"></b>&nbsp;</div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">来源</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b text="source"></b>&nbsp;</div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b text="activity.name"></b>&nbsp;</div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">联系人名称</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b text="contacts.fullName"></b>&nbsp;</div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b text="createBy"></b>&nbsp;&nbsp;
            <small style="font-size: 10px; color: gray;" text="createTime"></small>&nbsp;
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b text="editBy"></b>&nbsp;&nbsp;
            <small text="editTime" style="font-size: 10px; color: gray;"></small>&nbsp;
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 80px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b text="description"></b>&nbsp;
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 90px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b text="contactSummary"></b>&nbsp;
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 100px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b text="nextContactTime"></b>&nbsp;</div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div style="position: relative; top: 100px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <!-- 备注1 -->
    <div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="../../image/user-thumbnail.png" style="width: 30px; height:30px;">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>哎呦！</h5>
            <font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b>
            <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>

    <!-- 备注2 -->
    <div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="../../image/user-thumbnail.png" style="width: 30px; height:30px;">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>呵呵！</h5>
            <font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b>
            <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>

    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>
            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button type="button" class="btn btn-primary">保存</button>
            </p>
        </form>
    </div>
</div>

<!-- 阶段历史 -->
<div>
    <div style="position: relative; top: 100px; left: 40px;">
        <div class="page-header">
            <h4>阶段历史</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTable" class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>阶段</td>
                    <td>金额</td>
                    <td>可能性</td>
                    <td>预计成交日期</td>
                    <td>修改时间</td>
                    <td>修改者</td>
                </tr>
                </thead>
                <tbody id="dataBody"></tbody>
            </table>
        </div>

    </div>
</div>

<div style="height: 200px;"></div>

</body>
</html>