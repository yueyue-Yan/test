// 所有ajax执行完成之后都会执行的函数，如果不希望某个ajax执行该函数
// 则需要指定参数： global: false，即不执行全局函数
/*$(document).ajaxComplete(function(evt, request, settings) {
    var result = request.responseJSON;
    if ( result.success === false ) {
        location = "/error/indexView";
    }
});*/

// 设置ajax的全局默认参数，是可以覆盖的！
$.ajaxSetup({
    //type: "post"
    // 不管成功还是失败都会执行的方法
    complete: function (xhr) { // XMLHttpRequest
        //console.log(JSON.stringify(xhr));
        // if ( xhr.status == 200 ) {
        //     var result = xhr.responseJSON;
        //     if ( result.success === false ) {
        //         if ( result.relogin ) {
        //             alert("登录已失效，请重新登录！");
        //             location = "..";
        //         } else if(result.foreign) {
        //             alert(result.msg);
        //         } else {
        //             location = "/error/indexView";
        //         }
        //     }
        //}
        //else if
        if (xhr.status == 404) {
            location = "/error/indexView";
        }
    }
});