import "package:enos/constants.dart";
import 'package:enos/services/util.dart';
import "package:flutter/material.dart";
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatefulWidget {
  final List chartDataY;
  final List chartDataX;
  final double openPrice;
  final Color color;
  final bool isPreview;
  const LineChartWidget(
      {this.chartDataX,
      this.chartDataY,
      this.openPrice,
      this.color,
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

  @override
  Widget build(BuildContext context) {
    chartColor = widget.isPreview ? widget.color.withOpacity(0) : widget.color;

    for (var i = 0; i < widget.chartDataX.length; ++i) {
      chartDataPoints
          .add({"x": widget.chartDataX[i], "y": widget.chartDataY[i]});
    }
    minMaxX = Utils.maxMin(widget.chartDataX);
    minMaxY = Utils.maxMin(widget.chartDataY);
    return AspectRatio(
      aspectRatio: widget.isPreview ? 3 : 1.75,
      child: LineChart(
        LineChartData(
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: false,
              //getTouchLineEnd: ,

              touchCallback:
                  (FlTouchEvent event, LineTouchResponse touchResponse) {
                if (event is FlTapUpEvent) {
                  // handle tap here
                  print("up...");
                }
                if (event is FlTapDownEvent) {
                  print('down');
                }
                if (event is FlTapCancelEvent) {}
              },
            ),
            minX: minMaxX['min'],
            maxX: minMaxX['max'],
            minY: minMaxY['min'],
            maxY: minMaxY['max'],
            titlesData: FlTitlesData(show: false),
            gridData: FlGridData(
                show: false, drawHorizontalLine: false, drawVerticalLine: true),
            borderData: FlBorderData(show: false),
            // clipData: FlClipData.all(),
            extraLinesData: ExtraLinesData(
                extraLinesOnTop: false,
                horizontalLines: [
                  HorizontalLine(y: widget.openPrice, color: kDisabledColor)
                ]),
            lineBarsData: [
              LineChartBarData(
                  isStepLineChart: false,
                  belowBarData: BarAreaData(
                    show: true,
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
