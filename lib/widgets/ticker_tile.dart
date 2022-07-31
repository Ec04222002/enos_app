import 'dart:async';

import 'package:enos/services/ticker_page_info.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/models/user.dart';
import 'package:enos/models/watchlist.dart';
import 'package:enos/screens/ticker_info.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'package:enos/services/yahoo_api.dart';
import 'package:enos/widgets/line_chart.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/preview_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:enos/constants.dart';
import 'package:provider/provider.dart';

class TickerTile extends StatefulWidget {
  final int index;
  final BuildContext context;
  TickerTile({this.index, this.context, Key key}) : super(key: key);

  @override
  State<TickerTile> createState() => _TickerState();
}

class _TickerState extends State<TickerTile> {
  //for updating list
  TickerTileModel tickerTileData;
  TickerTileProvider tickerProvider;
  Widget trailingWidget;
  bool _toggle = false;

  @override
  Widget build(BuildContext context) {
    print("building tickertile");
    tickerProvider = Provider.of<TickerTileProvider>(widget.context);
    tickerTileData = tickerProvider.tickerAt(widget.index);
    trailingWidget =
        tickerProvider.isLive ? getStreamWidget(widget.context) : priceWidget();
    return tickerTileData == null
        ? Loading(
            type: "dot",
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Slidable(
              endActionPane: ActionPane(
                extentRatio: 0.2,
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    backgroundColor: kRedColor,
                    foregroundColor: kDarkTextColor,
                    icon: Icons.remove_circle,
                    onPressed: deleteTicker,
                  )
                ],
              ),
              key: Key(tickerTileData.symbol),
              child: buildTile(context),
            ));
  }

  Widget buildTile(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          showInfo(context, tickerTileData.symbol, tickerTileData.isSaved),
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        color: kLightBackgroundColor,
        child: ListTile(
          onTap: null,
          onLongPress: null,
          visualDensity: VisualDensity(horizontal: 0, vertical: 2.6),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          leading: Container(
            width: 135,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${tickerTileData.symbol}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 21,
                        color: kBrightTextColor,
                        fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    "${tickerTileData.companyName}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: kDisabledColor,
                    ),
                  ),
                ]),
          ),
          title: PreviewLineChart(
            symbol: tickerTileData.symbol,
            chartDataX: tickerTileData.chartDataX,
            chartDataY: tickerTileData.chartDataY,
            color: tickerTileData.percentChange[0] == "-"
                ? kRedColor
                : kGreenColor,
            previousClose: tickerTileData.previousClose,
          ),
          trailing: trailingWidget,
        ),
      ),
    );
  }

  Widget getStreamWidget(BuildContext context) {
    return StreamBuilder<TickerTileModel>(
        initialData: tickerTileData,
        stream: tickerProvider.getTileStream(tickerTileData.symbol),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return priceWidget();
            default:
              if (snapshot.hasError) {
                print(snapshot.error);
                return Text("Error - No Data",
                    style: TextStyle(color: kRedColor));
              } else {
                TickerTileModel data = snapshot.data;
                Provider.of<TickerTileProvider>(context)
                    .replaceTickerAt(widget.index, data);
                tickerTileData = data;
                return priceWidget();
              }
          }
        });
  }

  Widget priceWidget() {
    Color regularMarketChangeColor = kRedColor;
    Color postMarketChangeColor = kRedColor;
    String regularMarketOp = "";
    String postMarketOp = "";
    String suffix = "";
    String changeShown =
        _toggle ? tickerTileData.priceChange : tickerTileData.percentChange;
    String postChangeShown = _toggle
        ? tickerTileData.postPriceChange
        : tickerTileData.postPercentChange;
    double containerWidth = changeShown.length > 6 ? 70 : 60;
    double priceSize = tickerTileData.price.length > 9 ? 17 : 20;
    if (changeShown != null) {
      if (changeShown[0] != "-") {
        regularMarketChangeColor = kGreenColor;
        regularMarketOp = "+";
      }
      if (!_toggle && changeShown[changeShown.length - 1] != "%") {
        suffix = "%";
      }
    }
    if (postChangeShown != null && postChangeShown[0] != '-') {
      postMarketOp = "+";
      postMarketChangeColor = kGreenColor;
    }
    //print("in widget");
    return Container(
      width: 93,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "${tickerTileData.price}",
              style: TextStyle(
                  color: kBrightTextColor,
                  fontSize: priceSize,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 2),
            GestureDetector(
              onTap: () => setState(() {
                _toggle = !_toggle;
              }),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: regularMarketChangeColor),
                width: containerWidth,
                height: 16,
                child: Text("$regularMarketOp${changeShown}$suffix",
                    textAlign: TextAlign.right,
                    style: TextStyle(color: kBrightTextColor)),
              ),
            ),
            SizedBox(
              height: 2,
            ),
            (tickerTileData.postPercentChange != null)
                ? GestureDetector(
                    onTap: () => setState(() {
                      _toggle = !_toggle;
                    }),
                    child: RichText(
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      text: TextSpan(
                        text: "Post: ",
                        style: DefaultTextStyle.of(context).style.copyWith(
                            fontWeight: FontWeight.w500, fontSize: 12),
                        children: <TextSpan>[
                          TextSpan(
                              text: "$postMarketOp${postChangeShown}$suffix",
                              style: TextStyle(color: postMarketChangeColor))
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    height: 1,
                  ),
          ]),
    );
  }

  void deleteTicker(BuildContext context) {
    TickerTileProvider tickerProvider =
        Provider.of<TickerTileProvider>(context, listen: false);
    List<String> tickers = tickerProvider.symbols;
    tickerProvider.removeTicker(tickers.indexOf(tickerTileData.symbol));
  }

  void showInfo(BuildContext buildContext, String symbol, bool isSaved) async {
    Navigator.push(
        buildContext,
        MaterialPageRoute(
          builder: (context) => TickerInfo(
            uid: Provider.of<UserField>(buildContext, listen: false).userUid,
            symbol: symbol,
            isSaved: isSaved,
            provider: Provider.of<TickerTileProvider>(buildContext),
          ),
        ));
  }
}
