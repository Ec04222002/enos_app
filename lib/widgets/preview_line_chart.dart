import 'package:chart_sparkline/chart_sparkline.dart';
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
      child: Stack(
        children: [
          Sparkline(
            //kLine: ['first'],
            pointIndex: 0,
            pointColor: kDisabledColor,
            pointSize: 5,
            lineColor: color,
            lineWidth: 3.0,
            data: chartDataY.map((e) => e as double).toList(),
            fillMode: FillMode.below,
            //pointsMode: PointsMode.atIndex,

            //averageLine: true,
            fillGradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.6), color.withOpacity(0.4)],
            ),
          ),
          LineChartWidget(
            chartDataX: chartDataX,
            chartDataY: chartDataY,
            previousClose: previousClose,
            color: color,
            isPreview: true,
          )
        ],
      ),
    );
  }
}
