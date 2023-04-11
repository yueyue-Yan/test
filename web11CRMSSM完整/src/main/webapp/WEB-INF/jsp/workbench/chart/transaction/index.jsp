<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/jsp/include/commons_head.jsp" %>
</head>
<body>
<!-- 为ECharts准备一个具备大小（宽高）的Dom -->
<div id="main" style="width: 1200px;height:600px;margin-top:40px;"></div>
<script type="text/javascript">
    // 基于准备好的dom，初始化echarts实例
    var myChart = echarts.init(document.getElementById('main'));

    // 指定图表的配置项和数据,JSON配置：创建一个对象，并且给定一些属性即可
    //JSON格式： {}对象，[]数组或集合
    var option = {
        tooltip: {
            trigger: 'item',
            formatter: "{a} <br/>{b} : {c}"
        },
        toolbox: {
            feature: {
                //dataView: {readOnly: false},
                restore: {},
                //saveAsImage: {}
            }
        },
        legend: {
            data: ['01资质审查','02需求分析','03价值建议','04确定决策者','05提案/报价','06谈判/复审','07成交','08丢失的线索','09因竞争丢失关闭']
        },
        series: [
            {
                name:'漏斗图',
                type:'funnel',
                left: '10%',
                top: 60,
                //x2: 80,
                bottom: 60,
                width: '80%',
                // height: {totalHeight} - y - y2,
                min: 0,
                //max: 100,
                minSize: '0%',
                maxSize: '100%',
                sort: 'descending',
                gap: 2,
                label: {
                    show: true,
                    position: 'inside'
                },
                labelLine: {
                    length: 10,
                    lineStyle: {
                        width: 1,
                        type: 'solid'
                    }
                },
                itemStyle: {
                    borderColor: '#fff',
                    borderWidth: 1
                },
                emphasis: {
                    label: {
                        fontSize: 20
                    }
                },
                // ['01资质审查','02需求分析','03价值建议','04确定决策者','05提案/报价','06谈判/复审','07成交','08丢失的线索','09因竞争丢失关闭']
                data: [
                    {value: 30, name: '01资质审查'},
                    {value: 40, name: '02需求分析'},
                    {value: 60, name: '03价值建议'},
                    {value: 80, name: '04确定决策者'},
                    {value: 150, name: '05提案/报价'},
                    {value: 100, name: '06谈判/复审'},
                    {value: 300, name: '07成交'},
                    {value: 12, name: '08丢失的线索'},
                    {value: 8, name: '09因竞争丢失关闭'}
                ]
            }
        ]
    };

    // 发送ajax请求获取每个阶段对应的数量
    $.ajax({
        url: "/chart/transaction/getStageCount.json",
        success: function (data) {
             data =
                [
                    {value: 30, name: '01资质审查'},
                    {value: 40, name: '02需求分析'},
                    {value: 60, name: '03价值建议'},
                    {value: 80, name: '04确定决策者'},
                    {value: 150, name: '05提案/报价'},
                    {value: 100, name: '06谈判/复审'},
                    {value: 300, name: '07成交'},
                    {value: 12, name: '08丢失的线索'},
                    {value: 8, name: '09因竞争丢失关闭'}
                ]

            // 将数据替换成真实数据
            option.series[0].data = data;
            // ['01资质审查','02需求分析','03价值建议','04确定决策者','05提案/报价','06谈判/复审','07成交','08丢失的线索','09因竞争丢失关闭']
            /*var arr = [];
            for(var i=0; i<data.length; i++) {
                arr.push(data[i].name);
            }*/
            // 统计项
            option.legend.data = jQuery(data).map(function() {
                return this.name;
            }).get();

            // 使用刚指定的配置项和数据显示图表。
            myChart.setOption(option);
        }
    })



</script>
</body>
</html>