import 'package:enos/constants.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/line_chart.dart';
import 'package:flutter/material.dart';

class PreviewLineChart extends StatelessWidget {
  final List chartDataY;
  final List chartDataX;
  final Color color;
  final double previousClose;

  PreviewLineChart(
      {this.chartDataX,
      this.chartDataY,
      this.color,
      this.previousClose,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 3,
        child: LineChartWidget(
          chartDataX: chartDataX,
          chartDataY: chartDataY,
          previousClose: previousClose,
          color: color,
          isPreview: true,
        ));
  }
}
