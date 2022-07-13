import "package:enos/constants.dart";
import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/services/ticker_page_info.dart';
import 'package:enos/services/util.dart';
import "package:flutter/material.dart";
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatefulWidget {
  final TickerPageModel pageData;
  Color color;
  double openPrice;
  List chartDataX, chartDataY;
  final bool isPreview;
  LineChartWidget(
      {this.color,
      this.openPrice,
      this.chartDataX,
      this.chartDataY,
      this.pageData,
      this.isPreview,
      Key key})
      : super(key: key);

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<Map> chartDataPoints = [];
  Map minMaxX;
  Map minMaxY;
  Color chartColor;
  List chartDataY;
  List chartDataX;
  List closePriceData;
  List highPriceData;
  List lowPriceData;
  double openPrice;
  @override
  void initState() {
    super.initState();
    if (widget.pageData != null) {
      chartColor =
          widget.pageData.percentChange[0] == '-' ? kRedColor : kGreenColor;
      openPrice = widget.pageData.openPrice;
      chartDataY = widget.pageData.chartDataY;
      chartDataX = widget.pageData.chartDataX;
    } else {
      openPrice = widget.openPrice;
      chartDataX = widget.chartDataX;
      chartDataY = widget.chartDataY;
      chartColor = widget.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    //chartColor = widget.color;
    //print("openPrice: ${widget.openPrice}");
    for (var i = 0; i < chartDataX.length; ++i) {
      chartDataPoints.add({"x": chartDataX[i], "y": chartDataY[i]});
    }

    minMaxX = Utils.maxMin(chartDataX);
    minMaxY = Utils.maxMin(chartDataY);
    return AspectRatio(
      aspectRatio: widget.isPreview ? 3 : 1.75,
      child: LineChart(
        LineChartData(
            lineTouchData: LineTouchData(
              enabled: !widget.isPreview,
              handleBuiltInTouches: true,
              //getTouchLineEnd: ,
              touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                  getTooltipItems: (items) {
                    int index = items[0].spotIndex;
                    dynamic data = chartDataPoints[index];

                    //post data
                    //pageData is reference and will show after post update
                    closePriceData = widget.pageData.closePriceData;
                    highPriceData = widget.pageData.highPriceData;
                    lowPriceData = widget.pageData.lowPriceData;
                    // print("data: $data");
                    String openPrice = Utils.fixNumToFormat(
                      num: data['y'],
                      isPercentage: false,
                      isConstrain: false,
                      isMainData: true,
                    );
                    String closePrice = Utils.fixNumToFormat(
                      num: closePriceData[index],
                      isPercentage: false,
                      isConstrain: false,
                      isMainData: true,
                    );

                    String highPrice = Utils.fixNumToFormat(
                      num: highPriceData[index],
                      isPercentage: false,
                      isConstrain: false,
                      isMainData: true,
                    );
                    String lowPrice = Utils.fixNumToFormat(
                      num: lowPriceData[index],
                      isPercentage: false,
                      isConstrain: false,
                      isMainData: true,
                    );
                    List<LineTooltipItem> results = [
                      LineTooltipItem(
                        "*Open:\t${openPrice}\nClose:\t${closePrice}\nHigh:\t${highPrice}\nLow:\t${lowPrice}",
                        TextStyle(color: kBrightTextColor),
                        textAlign: TextAlign.start,
                      ),
                    ];
                    return results;
                  }),
              touchCallback:
                  (FlTouchEvent event, LineTouchResponse touchResponse) {
                if (event is FlTapUpEvent) {
                  // handle tap here
                  print("up...");
                }
                if (event is FlTapDownEvent) {}
                if (event is FlTapCancelEvent) {}
              },
            ),
            minX: minMaxX['min'],
            maxX: minMaxX['max'],
            minY: minMaxY['min'],
            maxY: minMaxY['max'],
            titlesData: FlTitlesData(show: false),
            gridData: FlGridData(
              show: !widget.isPreview,
              drawHorizontalLine: true,
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            //clipData: FlClipData.all(),
            extraLinesData:
                ExtraLinesData(extraLinesOnTop: false, horizontalLines: [
              HorizontalLine(
                y: openPrice,
                color: kDisabledColor,
                strokeWidth: 3,
              )
            ]),
            lineBarsData: [
              LineChartBarData(
                  isStepLineChart: false,
                  show: !widget.isPreview,
                  belowBarData: BarAreaData(
                    show: !widget.isPreview,
                    color: chartColor.withOpacity(0.4),
                  ),
                  color: chartColor,
                  isCurved: false,
                  dotData: FlDotData(show: false),
                  spots: chartDataPoints
                      .map((point) => FlSpot(point['x'], point['y']))
                      .toList()),
            ]),
        swapAnimationDuration: Duration(milliseconds: 150),
        swapAnimationCurve: Curves.linear,
      ),
    );
  }
}
