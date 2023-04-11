jQuery(function ($) {
    $.fn.extend({
        selectAll: function(checkboxSelector) {
            $(this).click(function () {
                $(checkboxSelector).prop("checked", this.checked);
            });

            var that = this;

            // 使用委派的方式为$(":checkbox[name=id]")绑定事件
            $("body").on("click", checkboxSelector, function () {
                $(that).prop("checked", $(checkboxSelector).size() == $(checkboxSelector+":checked").size());
            });

            // 保证 jQuery 的链式操作可以正常使用
            return $(this);
        }
    });
});
