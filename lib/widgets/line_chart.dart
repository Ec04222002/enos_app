import "package:enos/constants.dart";
import 'package:enos/services/util.dart';
import "package:flutter/material.dart";
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class LineChartWidget extends StatefulWidget {
  final List chartDataY;
  final List chartDataX;
  final double openPrice;
  const LineChartWidget(
      {this.chartDataX, this.chartDataY, this.openPrice, Key key})
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
    chartColor =
        widget.chartDataY[widget.chartDataY.length - 1] > widget.openPrice
            ? kGreenColor
            : kRedColor;

    for (var i = 0; i < widget.chartDataX.length; ++i) {
      chartDataPoints
          .add({"x": widget.chartDataX[i], "y": widget.chartDataY[i]});
    }
    minMaxX = Utils.maxMin(widget.chartDataX);
    minMaxY = Utils.maxMin(widget.chartDataY);

    return SizedBox(
      height: 30,
      child: LineChart(LineChartData(
          lineTouchData: LineTouchData(enabled: false),
          minX: minMaxX['min'],
          maxX: minMaxX['max'],
          minY: minMaxY['min'],
          maxY: minMaxY['max'],
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(
              show: false, drawHorizontalLine: false, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(y: widget.openPrice, color: kDisabledColor)
          ]),
          lineBarsData: [
            LineChartBarData(
                isStepLineChart: false,
                belowBarData: BarAreaData(
                  show: true,
                  colors: [chartColor.withOpacity(0.4)],
                ),
                colors: [chartColor],
                isCurved: false,
                dotData: FlDotData(show: false),
                spots: chartDataPoints
                    .map((point) => FlSpot(point['x'], point['y']))
                    .toList()),
          ])),
    );
  }
}
