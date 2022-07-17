import "package:enos/constants.dart";
import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/services/ticker_page_info.dart';
import 'package:enos/services/util.dart';
import "package:flutter/material.dart";
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatefulWidget {
  final TickerPageModel pageData;
  Color color;
  double previousClose;
  List chartDataX, chartDataY;
  final bool isPreview;
  LineChartWidget(
      {this.color,
      this.previousClose,
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

  List modTimeDataX = [];
  double previousClose;
  @override
  void initState() {
    super.initState();
    if (widget.pageData != null) {
      chartColor =
          widget.pageData.percentChange[0] == '-' ? kRedColor : kGreenColor;
      previousClose = widget.pageData.previousClose;
      chartDataY = widget.pageData.chartDataY;
      chartDataX = widget.pageData.chartDataX;
    } else {
      previousClose = widget.previousClose;
      chartDataX = widget.chartDataX;
      chartDataY = widget.chartDataY;
      chartColor = widget.color;
    }
    for (var i = 0; i < chartDataX.length; i++) {
      modTimeDataX.add(Utils.formatSideTitle(epoch: chartDataX[i]));
    }
  }

  String lastTime;
  Widget bottomTitleWidget(double value, TitleMeta _) {
    String time = Utils.formatSideTitle(epoch: value);
    int occur = modTimeDataX.where((value) => value == time).toList().length;
    if (occur <= 3 || time == lastTime) return Text("");
    lastTime = time;
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 23, 0, 0),
      child:
          Text("${time.replaceAll(" ", "")}", style: TextStyle(fontSize: 13)),
    );
  }

  String _optimalLabelSpot() {
    if (chartDataX.isEmpty) return "leftTop";
    if (chartDataX.length < 6) {
      if (chartDataY.first >= previousClose) return "leftBottom";
      return "leftTop";
    }
    //space with respect to amount of y's
    int space = (chartDataY.length * 0.1).round();

    List leftData = chartDataY.sublist(0, space);
    List centerData = chartDataY.length % 2 != 0
        ? chartDataY.sublist(
            (chartDataY.length / 2).floor() - (space / 2).round(),
            ((chartDataY.length / 2).floor() + (space / 2).round() + 1))
        : chartDataY.sublist(
            (chartDataY.length / 2).floor() - (space / 2).round(),
            ((chartDataY.length / 2).floor() + (space / 2).round()));
    List rightData = chartDataY.sublist(chartDataY.length - space);

    List datas = [leftData, centerData, rightData];
    //checking for most consecutive below or above
    List mostConsData;
    int maxConsCount = 0;
    bool isAbove;
    for (List data in datas) {
      //print('getting data: $data');
      //get each starting check value
      for (int i = 0; i < data.length; i++) {
        int consCount = 0;
        double valueToCheck = data[i].toDouble();
        isAbove = valueToCheck <= previousClose;
        //checking each value
        for (int j = i + 1; j < data.length; j++) {
          if ((data[j].toDouble() <= previousClose) == isAbove) {
            consCount++;
            continue;
          }
          break;
        }
        //print("consecutive: $consCount");
        //if left (default) side has cons => return default
        if (data == leftData && consCount > (0.5 * leftData.length).ceil()) {
          if (isAbove) return "topLeft";
          return "bottomLeft";
        }

        //setting maxconscount and data
        if (consCount > maxConsCount) {
          mostConsData = data;
          maxConsCount = consCount;
        }
      }
    }

    String topOrBottom = isAbove ? "top" : "bottom";
    String leftCenterOrRight = "Right";

    if (mostConsData == leftData) leftCenterOrRight = "Left";
    if (mostConsData == centerData) leftCenterOrRight = "Center";
    print("Result: ${topOrBottom + leftCenterOrRight}");
    return topOrBottom + leftCenterOrRight;
  }

  @override
  Widget build(BuildContext context) {
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
              getTouchedSpotIndicator:
                  (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  double value = barData.spots[spotIndex].y;
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: Colors.blueGrey,
                      strokeWidth: 2,
                      //dashArray: [4, 4],
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 8,
                          color:
                              value > previousClose ? kGreenColor : kRedColor,
                          strokeWidth: 2,
                          strokeColor: Colors.blueGrey,
                        );
                      },
                    ),
                  );
                }).toList();
              },
              touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: false,
                  tooltipBgColor: Colors.blueGrey,
                  getTooltipItems: (items) {
                    int index = items[0].spotIndex;
                    dynamic data = chartDataPoints[index];
                    String time = Utils.formatSideTitle(
                        epoch: chartDataX[index],
                        isTime: true,
                        isJustPrefix: false);
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
                        "Time:\t${time}\n*Open:\t${openPrice}\nClose:\t${closePrice}\nHigh:\t${highPrice}\nLow:\t${lowPrice}",
                        TextStyle(color: kBrightTextColor, fontSize: 13),
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
            minY:
                previousClose < minMaxY['min'] ? previousClose : minMaxY['min'],
            maxY:
                previousClose > minMaxY['max'] ? previousClose : minMaxY['max'],
            titlesData: FlTitlesData(
                show: !widget.isPreview,
                bottomTitles: AxisTitles(
                  //axisNameSize: 6,
                  drawBehindEverything: true,

                  sideTitles: SideTitles(
                      reservedSize: 40,
                      showTitles: true,
                      getTitlesWidget:
                          widget.isPreview ? null : bottomTitleWidget),
                ),
                topTitles: AxisTitles(
                    sideTitles: SideTitles(reservedSize: 0, showTitles: false)),
                rightTitles: AxisTitles(
                    sideTitles: SideTitles(reservedSize: 0, showTitles: false)),
                leftTitles: AxisTitles(
                    sideTitles:
                        SideTitles(reservedSize: 0, showTitles: false))),
            gridData: FlGridData(
              show: !widget.isPreview,
              drawHorizontalLine: true,
              drawVerticalLine: true,
            ),
            borderData: FlBorderData(show: false),
            //clipData: FlClipData.all(),
            extraLinesData:
                ExtraLinesData(extraLinesOnTop: false, horizontalLines: [
              HorizontalLine(
                  y: previousClose,
                  dashArray: [3, 3],
                  color: kDisabledColor,
                  strokeWidth: widget.isPreview ? 2 : 5.5,
                  label: HorizontalLineLabel(
                      show: !widget.isPreview,
                      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                      alignment: (() {
                        if (widget.isPreview) return Alignment.bottomLeft;
                        switch (_optimalLabelSpot()) {
                          case "topLeft":
                            return Alignment.topLeft;
                            break;
                          case "bottomLeft":
                            return Alignment.bottomLeft;
                            break;
                          case "topCenter":
                            return Alignment.topCenter;
                            break;
                          case "bottomCenter":
                            return Alignment.bottomCenter;
                            break;
                          case "topRight":
                            return Alignment.topRight;
                            break;
                          case "bottomRight":
                            return Alignment.bottomRight;
                            break;
                        }
                      }()),
                      labelResolver: (line) {
                        print("line: ${line.y}");
                        return Utils.fixNumToFormat(
                            num: line.y,
                            isPercentage: false,
                            isConstrain: false);
                      },
                      style: TextStyle(
                          color: kBrightTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w900)))
            ]),
            lineBarsData: [
              LineChartBarData(
                  isStepLineChart: false,
                  show: !widget.isPreview,
                  belowBarData: BarAreaData(
                    applyCutOffY: true,
                    cutOffY: previousClose,
                    show: true,
                    color: kGreenColor.withOpacity(0.75),
                  ),
                  aboveBarData: BarAreaData(
                      show: true,
                      applyCutOffY: true,
                      cutOffY: previousClose,
                      color: Utils.darken(kRedColor, 0.25)),
                  //color: kDarkTextColor,
                  color: Colors.blueGrey,
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
