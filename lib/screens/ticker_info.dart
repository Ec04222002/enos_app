// ticker/chart page

import 'dart:math';

import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/services/ticker_page_info.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/line_chart.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/pre_ticker_prices.dart';
import 'package:flutter/material.dart';
import 'package:enos/constants.dart';
import 'package:provider/provider.dart';

class TickerInfo extends StatefulWidget {
  final String symbol;
  final bool isSaved;
  final TickerTileProvider provider;
  const TickerInfo({this.symbol, this.isSaved, this.provider, Key key})
      : super(key: key);

  @override
  State<TickerInfo> createState() => _TickerInfoState();
}

class _TickerInfoState extends State<TickerInfo> {
  bool isLoading = true;
  double btnOpacity = 0.2;
  TickerPageModel pageData;
  Future<void> init() async {
    pageData = await TickerPageInfo.getModelData(widget.symbol, widget.isSaved);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    //get all new updates
    init();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading(
            type: "dot",
            loadText: "Loading" " ${widget.symbol} ....",
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                color: kDarkTextColor,
                icon: Icon(Icons.arrow_back_ios),
              ),
              centerTitle: true,
              backgroundColor: kLightBackgroundColor,
              title: Text(
                //${pageInfo.shortName()} * ${tileData.price}
                pageData.shortName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: kBrightTextColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
                maxLines: 2,
              ),
            ),
            floatingActionButton: GestureDetector(
              onLongPress: () {
                Utils.showSnackBar(context, "Streaming Data ...");
                //print("in long press");
                setState(() {
                  btnOpacity = 0;
                });
              },
              onLongPressEnd: (_) {
                //print("end press");
                setState(() {
                  btnOpacity = 0.2;
                });
              },
              onLongPressCancel: () {
                //print("cancel press");
                setState(() {
                  btnOpacity = 0.2;
                });
              },
              onTap: () {
                //print("tap");
                setState(() {
                  btnOpacity = 0.2;
                });
              },
              onTapCancel: () {
                //print("tap cancel");
                setState(() {
                  btnOpacity = 0.2;
                });
              },
              onTapUp: (_) {
                //print('tap up');
                setState(() {
                  btnOpacity = 0.2;
                });
              },
              child: FloatingActionButton(
                child: Icon(
                  Icons.keyboard_double_arrow_up_outlined,
                  size: 50,
                  color: kDarkTextColor,
                ),
                backgroundColor: kActiveColor.withOpacity(btnOpacity),
              ),
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: PreTickerInfo(
                    data: pageData,
                    tickerProvider: widget.provider,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: LineChartWidget(
                    chartDataX: pageData.chartDataX,
                    chartDataY: pageData.chartDataY,
                    openPrice: pageData.openPrice,
                    color: pageData.percentChange[0] == '-'
                        ? kRedColor
                        : kGreenColor,
                    isPreview: false,
                  ),
                ),
              ],
            )),
          );
  }
}
