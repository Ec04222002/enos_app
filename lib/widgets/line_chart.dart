import "package:enos/constants.dart";
import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/models/user.dart';
import 'package:enos/screens/ticker_info.dart';
import 'package:enos/services/ticker_page_info.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/loading.dart';
import "package:flutter/material.dart";
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LineChartWidget extends StatefulWidget {
  final TickerPageModel pageData;
  final bool isPreview;
  final chartLoading;
  final symbol;
  //final lowData;
  Color color;
  double previousClose;
  List chartDataX, chartDataY;
  String range;

  LineChartWidget(
      {this.color,
      this.previousClose,
      this.chartLoading = false,
      this.symbol,
      this.chartDataX,
      this.chartDataY,
      this.range = '1d',
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
  //open price
  List chartDataY;
  List chartDataX;
  List chartDataXMod;
  List closePriceData;
  List highPriceData;
  List lowPriceData;
  bool triggerNewChartData = false;
  String defaultRange = "1d";
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
    setDataPoints();
  }

//for chart side titles
  String formatTime(
      {double epoch,
      bool isTime = false,
      bool isJustPrefix = true,
      isDay = false,
      isDate = false,
      isMonth = false,
      isYear = false}) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch((epoch * 1000).toInt());
    String result;
    if (isTime) {
      result = DateFormat("hh aa").format(time);
      if (!isJustPrefix) {
        result = DateFormat("hh:mm aa").format(time);
      }
      if (result.startsWith("0")) result = result.replaceFirst("0", "");
    } else if (isDay) {
      result = DateFormat("E").format(time);
    } else if (isDate) {
      result = DateFormat('MMMd').format(time);
    } else if (isMonth) {
      result = DateFormat('MMM').format(time);
    } else {
      result = DateFormat('y').format(time);
    }

    return result;
  }

  String getFormattedTime({double epoch, bool isPrefix = true}) {
    String time = "";
    switch (widget.range) {
      case '1d':
        time = formatTime(epoch: epoch, isTime: true, isJustPrefix: isPrefix);
        break;
      case '5d':
        time = formatTime(epoch: epoch, isDay: true, isJustPrefix: isPrefix);
        break;
      case '1mo':
        time = formatTime(epoch: epoch, isDate: true, isJustPrefix: isPrefix);
        break;
      case '6mo':
        time = formatTime(epoch: epoch, isMonth: true, isJustPrefix: isPrefix);
        break;
      case '1y':
        time = formatTime(epoch: epoch, isMonth: true, isJustPrefix: isPrefix);
        break;
      case '5y':
        time = formatTime(epoch: epoch, isYear: true, isJustPrefix: isPrefix);
        break;
      case 'max':
        time = formatTime(epoch: epoch, isYear: true, isJustPrefix: isPrefix);
        break;
    }
    return time;
  }

  void setDataPoints() {
    modTimeDataX = [];
    chartDataPoints = [];
    chartDataXMod = [];
    //List chartSection = [];
    for (var i = 0; i < chartDataX.length; i++) {
      modTimeDataX.add(getFormattedTime(
        epoch: chartDataX[i],
      ));
      double dataX = chartDataX[i];
      //set modified time stamp to remove market close gaps
      if (widget.range == "5d") {
        dataX = i * 900.0;
        chartDataXMod.add(dataX);
      }
      if (widget.range == "1mo") {
        dataX = i * 1800.0;
        chartDataXMod.add(dataX);
      }
      chartDataPoints.add({"x": dataX, "y": chartDataY[i]});
      print("time: ${modTimeDataX[i]}, data: ${chartDataY[i]}");
    }
  }

  bool isLabelUp() {
    int firstSpace = (chartDataY.length * 0.1).round();
    List upData = chartDataY
        .take(firstSpace)
        .where((element) => element > previousClose)
        .toList();
    return upData.length <= (0.5 * firstSpace).round();
  }

  String lastTime;
  Widget bottomTitleWidget(double value, TitleMeta _) {
    String time = getFormattedTime(epoch: value);
    int occur = modTimeDataX.where((value) => value == time).toList().length;
    if (occur <= 3 || time == lastTime) return Text("");
    lastTime = time;
    Widget timeWidget =
        Text(time.replaceAll(" ", ""), style: TextStyle(fontSize: 12));
    return Padding(
      padding: EdgeInsets.fromLTRB(7, 23, 7, 0),
      child: timeWidget,
    );
  }

  @override
  Widget build(BuildContext bContext) {
    //no Data

    if (widget.chartLoading) {
      print("chart is loading");
      return AspectRatio(
        aspectRatio: widget.isPreview ? 3 : 1.5,
        child: Loading(
          type: 'dot',
        ),
      );
    }

    // in data not default => init switch dates in chart page
    if (widget.range != defaultRange) {
      triggerNewChartData = true;
    }
    //occurs only in chart page
    if (triggerNewChartData) {
      if (widget.pageData.priceData[widget.range].isEmpty) {
        return AspectRatio(
            aspectRatio: widget.isPreview ? 3 : 1.5,
            child: Center(
                child: Text(
              "No Data",
              style: TextStyle(fontSize: 22),
            )));
      }
      print("showing new chart");
      chartDataX = widget.pageData.priceData[widget.range]['timeStamps'];
      chartDataY = widget.pageData.priceData[widget.range]['openPrices'];
      previousClose = widget.previousClose;
      setDataPoints();
    }

    print(chartDataX.length);
    print(chartDataY.length);
    minMaxX = widget.range == "5d" || widget.range == "1mo"
        ? Utils.maxMin(chartDataXMod)
        : Utils.maxMin(chartDataX);
    minMaxY = Utils.maxMin(chartDataY);
    return AspectRatio(
      aspectRatio: widget.isPreview ? 3 : 1.5,
      child: LineChart(
        LineChartData(
            baselineY: previousClose,
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
                  tooltipPadding: EdgeInsets.all(9),
                  maxContentWidth: 180,
                  fitInsideHorizontally: true,
                  fitInsideVertically: false,
                  tooltipBgColor: Colors.blueGrey,
                  getTooltipItems: (items) {
                    int index = items[0].spotIndex;
                    dynamic data = chartDataPoints[index];
                    String time = Utils.formatEpoch(
                        epoch: chartDataX[index].toInt(),
                        isJustTime: false,
                        isDateNumeric: true);
                    //post data
                    //pageData is reference and will show after post update
                    Map preData = widget.pageData.priceData[widget.range];
                    if (preData == null) {
                      List<LineTooltipItem> results = [
                        LineTooltipItem(
                          "Loading ...",
                          TextStyle(color: kBrightTextColor, fontSize: 13),
                          //textAlign: TextAlign.c,
                        ),
                      ];
                      return results;
                    }
                    closePriceData = preData['closePrices'];
                    highPriceData = preData['highPrices'];
                    lowPriceData = preData['lowPrices'];

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
                        "${time}\n*Open:\t${openPrice}\nClose:\t${closePrice}\nHigh:\t${highPrice}\nLow:\t${lowPrice}",
                        TextStyle(color: kBrightTextColor, fontSize: 13),
                        //textAlign: TextAlign.start,
                      ),
                    ];
                    return results;
                  }),
              touchCallback:
                  (FlTouchEvent event, LineTouchResponse touchResponse) {
                if (event is FlTapUpEvent && widget.isPreview) {
                  // handle tap here
                  //bContext = the main page context
                  //since this only occurs in preview page

                  Navigator.push(
                      bContext,
                      MaterialPageRoute(
                        builder: (context) => TickerInfo(
                          uid: Provider.of<UserField>(bContext, listen: false)
                              .userUid,
                          symbol: widget.symbol,
                          isSaved: true,
                          provider: Provider.of<TickerTileProvider>(bContext),
                        ),
                      ));
                  print("up...");
                }
                // if (event is FlTapDownEvent) {}
                // if (event is FlTapCancelEvent) {}
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
                          (widget.isPreview ? null : bottomTitleWidget)),
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
              getDrawingHorizontalLine: (value) {
                return FlLine(
                    color: kDisabledColor.withOpacity(0.2), strokeWidth: 1);
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                    color: kDarkTextColor.withOpacity(0.2), strokeWidth: 1);
              },
              drawHorizontalLine: true,
              drawVerticalLine: true,
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.transparent, width: 18),
            ),
            //clipData: FlClipData.all(),
            extraLinesData:
                ExtraLinesData(extraLinesOnTop: true, horizontalLines: [
              HorizontalLine(
                  y: previousClose,
                  dashArray: [4, 4],
                  color: kDisabledColor,
                  strokeWidth: 3,
                  label: HorizontalLineLabel(
                      show: !widget.isPreview,
                      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                      alignment: isLabelUp()
                          ? Alignment.topLeft
                          : Alignment.bottomLeft,
                      labelResolver: (line) {
                        return Utils.fixNumToFormat(
                            num: line.y,
                            isPercentage: false,
                            isConstrain: false);
                      },
                      style: TextStyle(
                          color: kBrightTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)))
            ]),
            lineBarsData: [
              LineChartBarData(
                  isStepLineChart: false,
                  show: true,
                  belowBarData: BarAreaData(
                    applyCutOffY: true,
                    cutOffY: previousClose,
                    show: true,
                    color: widget.isPreview
                        ? kGreenColor
                        : kGreenColor.withOpacity(0.85),
                  ),
                  aboveBarData: BarAreaData(
                      show: true,
                      applyCutOffY: true,
                      cutOffY: previousClose,
                      color: widget.isPreview
                          ? kRedColor
                          : Utils.darken(kRedColor, 0.25).withOpacity(0.85)),
                  //color: kDarkTextColor,
                  //preventCurveOverShooting: true,
                  //curveSmoothness: 1,
                  isStrokeCapRound: true,
                  isStrokeJoinRound: true,
                  barWidth: 1.5,
                  color: Colors.blueGrey,
                  //color: Colors.transparent,
                  //isCurved: true,
                  dotData: FlDotData(show: false),
                  spots: chartDataPoints
                      .map((point) => FlSpot(point['x'], point['y']))
                      .toList()),
            ]),
        swapAnimationDuration: Duration(milliseconds: 300),
        swapAnimationCurve: Curves.linear,
      ),
    );
  }
}
