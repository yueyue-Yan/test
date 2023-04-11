<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link href="/jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="/jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="/jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript">

	//页面加载完毕
	jQuery(function($) {
		
		//导航中所有文本颜色为黑色
		$(".liClass > a").css("color" , "black");
		
		//默认选中导航菜单中的第一个菜单项
		$(".liClass:first").addClass("active");
		
		//第一个菜单项的文字变成白色
		$(".liClass:first > a").css("color" , "white");
		
		//给所有的菜单项注册鼠标单击事件
		$(".liClass").click(function(){
			//移除所有菜单项的激活状态
			$(".liClass").removeClass("active");
			//导航中所有文本颜色为黑色
			$(".liClass > a").css("color" , "black");
			//当前项目被选中
			$(this).addClass("active");
			//当前项目颜色变成白色
			$(this).children("a").css("color","white");
		});
		
		//展示市场活动页面
		window.open("/main/indexView","workareaFrame");

		$("#logoutBtn").click(function () {
			// 退出：请求后台，将session中的user移除，或者将session销毁
			location = "/user/logout.do";
		});
	});
	
</script>

</head>
<body>
	
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
						姓名：<b>${sessionScope.user.name}</b><br><br>
						登录帐号：<b>${sessionScope.user.loginAct}</b><br><br>
						组织机构：<b>1005，市场部，二级部门</b><br><br>
						邮箱：<b>${sessionScope.user.email}</b><br><br>
						失效时间：<b>${sessionScope.user.expireTime}</b><br><br>
						允许访问IP：<b>${sessionScope.user.allowIps}</b>
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
					<button type="button" class="btn btn-primary" data-dismiss="modal" onclick="window.location.href='../login.jsp';">更新</button>
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
					<button id="logoutBtn" type="button" class="btn btn-primary" data-dismiss="modal">确定</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 顶部 -->
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2020&nbsp;悦悦小系统</span></div>
		<div style="position: absolute; top: 15px; right: 15px;">
			<ul>
				<li class="dropdown user-dropdown">
					<a href="javascript:void(0)" style="text-decoration: none; color: white;" class="dropdown-toggle" data-toggle="dropdown">
						<span class="glyphicon glyphicon-user"></span> ${sessionScope.user.name}    <span class="caret"></span>
					</a>
					<ul class="dropdown-menu">
						<li><a href="/settings/indexView"><span class="glyphicon glyphicon-wrench"></span> 系统设置</a></li>
						<li><a href="javascript:void(0)" data-toggle="modal" data-target="#myInformation"><span class="glyphicon glyphicon-file"></span> 我的资料</a></li>
						<li><a href="javascript:void(0)" data-toggle="modal" data-target="#editPwdModal"><span class="glyphicon glyphicon-edit"></span> 修改密码</a></li>
						<li><a href="javascript:void(0);" data-toggle="modal" data-target="#exitModal"><span class="glyphicon glyphicon-off"></span> 退出</a></li>
					</ul>
				</li>
			</ul>
		</div>
	</div>
	
	<!-- 中间 -->
	<div id="center" style="position: absolute;top: 50px; bottom: 30px; left: 0px; right: 0px;">
	
		<!-- 导航 -->
		<div id="navigation" style="left: 0px; width: 18%; position: relative; height: 100%; overflow:auto;">
		
			<ul id="no1" class="nav nav-pills nav-stacked">
				<li class="liClass"><a href="main/index.jsp" target="workareaFrame"><span class="glyphicon glyphicon-home"></span> 工作台</a></li>
				<li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-tag"></span> 动态</a></li>
				<li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-time"></span> 审批</a></li>
				<li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-user"></span> 客户公海</a></li>
				<li class="liClass"><a href="/act/indexView" target="workareaFrame"><span class="glyphicon glyphicon-play-circle"></span> 市场活动</a></li>
				<li class="liClass"><a href="/clue/indexView" target="workareaFrame"><span class="glyphicon glyphicon-search"></span> 线索（潜在客户）</a></li>
				<li class="liClass"><a href="/customer/indexView" target="workareaFrame"><span class="glyphicon glyphicon-user"></span> 客户</a></li>
				<li class="liClass"><a href="/contacts/indexView" target="workareaFrame"><span class="glyphicon glyphicon-earphone"></span> 联系人</a></li>
				<li class="liClass"><a href="/transaction/indexView" target="workareaFrame"><span class="glyphicon glyphicon-usd"></span> 交易（商机）</a></li>
				<li class="liClass"><a href="/visit/index.html" target="workareaFrame"><span class="glyphicon glyphicon-phone-alt"></span> 售后回访</a></li>
				<li class="liClass">
					<a href="#no2" class="collapsed" data-toggle="collapse"><span class="glyphicon glyphicon-stats"></span> 统计图表</a>
					<ul id="no2" class="nav nav-pills nav-stacked collapse">
						<li class="liClass"><a href="/chart/activity/indexView" target="workareaFrame">&nbsp;&nbsp;&nbsp;<span class="glyphicon glyphicon-chevron-right"></span> 市场活动统计图表</a></li>
						<li class="liClass"><a href="/chart/clue/index.html" target="workareaFrame">&nbsp;&nbsp;&nbsp;<span class="glyphicon glyphicon-chevron-right"></span> 线索统计图表</a></li>
						<li class="liClass"><a href="/chart/customerAndContacts/index.html" target="workareaFrame">&nbsp;&nbsp;&nbsp;<span class="glyphicon glyphicon-chevron-right"></span> 客户和联系人统计图表</a></li>
						<li class="liClass"><a href="/chart/transaction/indexView" target="workareaFrame">&nbsp;&nbsp;&nbsp;<span class="glyphicon glyphicon-chevron-right"></span> 交易统计图表</a></li>
					</ul>
				</li>
				<li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-file"></span> 报表</a></li>
				<li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-shopping-cart"></span> 销售订单</a></li>
				<li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-send"></span> 发货单</a></li>
				<li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-earphone"></span> 跟进</a></li>
				<li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-leaf"></span> 产品</a></li>
				<li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-usd"></span> 报价</a></li>
			</ul>
			
			<!-- 分割线 -->
			<div id="divider1" style="position: absolute; top : 0px; right: 0px; width: 1px; height: 100% ; background-color: #B3B3B3;"></div>
		</div>
		
		<!-- 工作区 -->
		<div id="workarea" style="position: absolute; top : 0px; left: 18%; width: 82%; height: 100%;">
			<iframe style="border-width: 0px; width: 100%; height: 100%;" name="workareaFrame"></iframe>
		</div>
		
	</div>
	
	<div id="divider2" style="height: 1px; width: 100%; position: absolute;bottom: 30px; background-color: #B3B3B3;"></div>
	
	<!-- 底部 -->
	<div id="down" style="height: 30px; width: 100%; position: absolute;bottom: 0px;"></div>
	
</body>
</html>