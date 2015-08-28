 /*  自定义confirm  使用jquery的Deferred实现
            调用方式
            HMBConfirm("？")
                .done(function () {
                    //确认
                }).fail(function () {
                    //取消
                })
        */
        function HMBConfirm(msg) {
            var df = $.Deferred();
            var $div = $("#deleteConfirm");
            $div.find("button").click(function () {
                if (this.value == "sure") {
                    df.resolve();
                }
                else {
                    df.reject();
                }

            });
            $("#deleteConfirm > bezel").html(msg);
            $div.show();
            $(".shade").show();
            return df.promise();
        }
