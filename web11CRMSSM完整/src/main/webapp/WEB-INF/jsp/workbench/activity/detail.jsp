<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
<%@ include file="/WEB-INF/jsp/include/commons_head.jsp"%>
<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
			reset();
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

		function load() {

			// 清空之前的备注
			$("div.remarkDiv").remove();

			// 加载市场活动详细信息（包含备注列表）
			$.ajax({
				//EL表达式：美元符号{param.id}
				url: "/act/getRemark.json?id=${param.id}",
				success: function (data) {


					//alert(JSON.stringify(data));

					/*

                        在进行页面渲染之前，我们为所有需要渲染数据的标签，统一添加了一个自定义属性text
                        该属性的值是data中的key，即市场活动中对应的属性名，这样的话，我们就可以使用
                        统一的方式为这些标签渲染数据了！
                     */

					// 查询所有包含text属性的元素（需要初始化数据的标签）
					// 当text方法中是一个函数的时候，该函数返回的值，就是标签中的文本
					$("[text]").text(function () {
						// $(this).attr("text")  获取的是要显示（data中）的属性
						return data[ $(this).attr("text") ];
					});

					// 123456789.124567 ===> 123,456,789.124567
                    $("[text=cost]").text(data.cost.replace(/\B(?<!(\.\d+))(?=(\d{3})+\b)/g, ","));

					// 初始化备注列表
					var arr = data.remarks;
                    console.log("data.remarks:" + data.remarks);
					$(arr).each(function() {
						// append是往元素的最后位置追加

						var text1 = this.noteTime + " 由" + this.notePerson;

						$("#remarkDiv").before(
							'<div class="remarkDiv" style="height: 60px;">\
								<img title="zhangsan" src="/image/user-thumbnail.png" style="width: 30px; height:30px;">\
								<div style="position: relative; top: -40px; left: 40px;" >\
									<h5 id="'+this.id+'">'+this.noteContent+'</h5>\
									<font color="gray">市场活动</font> <font color="gray">-</font> <b>'+data.name+'</b> <small style="color: gray;">'+text1+'</small>\
									<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">\
										<a edit="'+this.id+'" class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>\
										&nbsp;&nbsp;&nbsp;&nbsp;\
										<a del="'+this.id+'" class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>\
									</div>\
								</div>\
							</div>'
						)

					});

				}
			});
		}

		load();


		$("#savenBtn").click(function () {
			$.ajax({
				url: "/act/saveRemark.do",
				type: "post",
				data: {
					noteContent: $("#remark").val(),
					marketingActivitiesId: "${param.id}",
					id: currRemarkId
				},
				success: function (data) {
					if(data.success) {
						reset();
						load();
						$.alert("操作成功！");
					}
				}
			})
		});

		function reset() {
			// 清除当前正在编辑的备注
			$("#remark").val("");
			currRemarkId = undefined;
		}

		$("#remarkList").on("click", "a[del]", function () {

			var that = this;

			$.confirm("确定删除吗？", function () {
				$.ajax({
					url: "/act/delRemark.do?id=" + $(that).attr("del"),
					type: "delete",
					success: function (data) {
						if(data.success) {
							load();
							$.alert("操作成功！");
						}
					}
				})
			});

			/*$.confirm("确定删除吗？", () => {
				$.ajax({
					url: "/act/delRemark.do?id=" + $(this).attr("del"),
					type: "delete",
					success: function (data) {
						if(data.success) {
							load();
							$.alert("操作成功！");
						}
					}
				});
			});*/

		});

		var currRemarkId; //用变量代替隐藏域，当前正在操作的备注id
		$("#remarkList").on("click", "a[edit]", function () {
			currRemarkId = $(this).attr("edit");
			// <h5 id="cb6d61357e184d3aae0cc629a094b159">备注内容</h5>
			var content = $("#" + currRemarkId).text();
			$("#remark").val(content);
		});



	});
	
</script>

</head>
<body>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>市场活动-<span text="name"></span> <small><span text="startDate"></span> ~ <span text="endDate"></span></small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b text="owner"></b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b text="name"></b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b text="startDate"></b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b text="endDate"></b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b text="cost"></b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b text="createBy"></b>&nbsp;&nbsp;<small text="createTime" style="font-size: 10px; color: gray;"></small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b text="editBy"></b>&nbsp;&nbsp;<small text="editTime" style="font-size: 10px; color: gray;"></small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b text="description"></b>&nbsp;
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 30px; left: 40px;" id="remarkList">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
		<%--<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="../../image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<input type="hidden" id="remarkId" />
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button id="savenBtn" type="button" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>