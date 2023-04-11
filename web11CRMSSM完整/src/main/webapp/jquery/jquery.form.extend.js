(function($) {
	$.fn.extend({
		/*
		 * 初始化表单
		 * 
		 * 如果指定的参数是URL, 则根据URL返回的json进行初始化 
		 * 否则直接使用指定的数据进行初始化
		 */
        initForm: function(data) {
			var _this = this;
			if ($.type(data) === "string") {
				$.get(data, function(data) {
					_initForm(data);
				}, "json");
			} else {
				_initForm(data);
			}
			function _initForm(data) {
				/*for (var name in data) {
					var val = data[name];
					var $el = _this.find('[name=' + name + ']');
					if ($el.is('select,:radio,:checkbox')) {
						val = (val + '').split(",");
					}
					$el.val(val);
				}*/
				_this.find(":input[name]").each(function() {
					var val = data[this.name] || '';
					if ( $(this).is("select,:radio,:checkbox") ) {
						val = (val + '').split(",");
					}
					$(this).val(val);
				});
			}
			return this;
        },
		
		findInput: function() {
        	var $1 = this.find(':text[name]');
        	var $2 = this.find(':password[name]');
        	var $3 = this.find(':radio[name]:checked');
        	var $4 = this.find(':checkbox[name]:checked');
        	var $5 = this.find('select[name]');
        	var $6 = this.find('textarea[name]');
        	var $7 = this.find(':file[name]').filter(function() {return this.files.length > 0});
        	var $8 = this.find('input:hidden');
			return $1.add($2).add($3).add($4).add($5).add($6).add($7).add($8);
		},
		
		// 提取表单数据，并转化为json
		// multipleToArr: 如果存在多值，将多值转换成数组，默认为true
		formJSON: function(multipleToArr) {
			var o = {};
			this.findInput().each(function() {
				var val = $(this).val();
				if ($(this).is('select') && this.multiple && val.length == 1) {
					val = val[0];
				}
				if ($(this).is(':file')) {
					val = this.files;
					if (val.length == 1) {
						val = val[0];
					}
				}
				if (o[this.name] === undefined) {
					o[this.name] = val;
				} else {
					if (!o[this.name].push) {
						o[this.name] = [ o[this.name] ];
					}
					o[this.name].push(val);
				}	
			});
			
			if (multipleToArr === false) {
				for (var k in o) {
					if(o[k] instanceof Array) {
						o[k] = o[k].join(",");
					}
				}
			}
			
			return o;
		},
		
		// 提取表单数据，并转化为formData
		formData: function() {
			var formData = new FormData();
			this.findInput().each(function(i, f) {
				if (this.type == 'file') {
					$(this.files).each(function() {
						formData.append(f.name, this);
					});
				} else if ($(this).is("select")) {
					var val = $(this).val();
					if (this.multiple) {
						for (var i = 0; i < val.length; i++) {
							formData.append(this.name, val[i]);
						}
					} else {
						formData.append(this.name, val);
					}
				} else {
					formData.append(this.name, $(this).val());
				}
			});
			
			return formData;
		}
    });
})(jQuery);