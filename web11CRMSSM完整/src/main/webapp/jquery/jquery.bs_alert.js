(function ($) {
    var randomStr = Math.random().toString().replace(".", "")
        , dialogid = "jQuery_dialog" + randomStr
        , okid = "jQuery_ok" + randomStr
        , cancelid = "jQuery_cancel" + randomStr;

    $.alert = function (msg, callback) {
        $("#" + cancelid).hide();
        $("#" + dialogid).modal('show').find('.modal-body').text(msg);
        if(typeof(callback) == "function") {
            $("#" + okid).one("click", callback);
        }
    };

    $.confirm = function (msg, fn) {
        this.alert(msg);
        $("#" + cancelid).show();
        // 一次性事件
        $("#" + okid).one("click", fn);
    };

    $(function () {
        $("body").append(
            '<div id="' + dialogid + '" class="modal" role="dialog">\
                <div class="modal-dialog" role="document" style="width:auto;min-width:300px;margin:0;position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);">\
                    <div class="modal-content">\
                        <div class="modal-body"></div>\
                        <div class="modal-footer">\
                            <button id="' + okid + '" type="button" class="btn btn-primary" data-dismiss="modal">确定</button>\
                            <button id="' + cancelid + '" type="button" class="btn btn-default" style="display:none;" data-dismiss="modal">取消</button>\
                        </div>\
                    </div>\
                </div>\
            </div>'
        );
    })
})(jQuery);