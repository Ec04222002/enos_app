import 'dart:async';
import 'dart:convert';

import 'package:enos/models/ticker_tile.dart';
import 'package:enos/models/user.dart';
import 'package:enos/models/watchlist.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/yahoo_api.dart';
import 'package:enos/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:enos/constants.dart';
import 'package:provider/provider.dart';

class TickerTile extends StatefulWidget {
  final TickerTileModel tickerTileData;
  TickerTile({this.tickerTileData, Key key}) : super(key: key);

  @override
  State<TickerTile> createState() => _TickerState();
}

class _TickerState extends State<TickerTile> {
  //for updating list
  TickerTileModel tickerTileData;
  YahooApi api = YahooApi();
  //create tile from yahoo api

  @override
  Widget build(BuildContext context) {
    tickerTileData = widget.tickerTileData;
    return tickerTileData == null
        ? Loading()
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
      onTap: () => showInfo(context, tickerTileData),
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        color: kLightBackgroundColor,
        child: ListTile(
          title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 7,
                ),
                Text(
                  "${tickerTileData.symbol}",
                  style: TextStyle(
                      fontSize: 21,
                      color: kBrightTextColor,
                      fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "${tickerTileData.companyName}",
                  style: TextStyle(
                    fontSize: 12,
                    color: kDisabledColor,
                  ),
                ),
                SizedBox(height: 6),
              ]),
          trailing: StreamBuilder<TickerTileModel>(
              initialData: tickerTileData,
              stream: api.getTileStream(tickerTileData.symbol),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return priceWidget(
                        tickerTileData.price, tickerTileData.percentChange);
                  default:
                    if (snapshot.hasError) {
                      if (snapshot.error ==
                          "Exception: Failed to load json data") {
                        print("reseting api key");
                        api.resetApiKey(api.increApiIndex());
                        return null;
                      }
                      return Text("Error", style: TextStyle(color: kRedColor));
                    } else {
                      TickerTileModel data = snapshot.data;
                      tickerTileData = data;
                      return priceWidget(data.price, data.percentChange);
                    }
                }
              }),
        ),
      ),
    );
  }

  Widget priceWidget(String price, String percentChange) {
    print("in widget");
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          SizedBox(height: 3),
          Text(
            "$price",
            style: TextStyle(
                color: kBrightTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 5),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: tickerTileData.percentChange[0] == "-"
                    ? kRedColor
                    : kGreenColor),
            width: 60,
            height: 20,
            child: Text("$percentChange",
                textAlign: TextAlign.right,
                style: TextStyle(color: kBrightTextColor)),
          )
        ]);
  }

  void deleteTicker(BuildContext context) {
    TickerTileProvider tickerProvider =
        Provider.of<TickerTileProvider>(context, listen: false);
    List<String> tickers = tickerProvider.symbols;
    tickerProvider.removeTicker(tickers.indexOf(tickerTileData.symbol));
    tickers.remove(tickerTileData.symbol);
    FirebaseApi.updateWatchList(Watchlist(
        watchlistUid: tickerProvider.watchListUid,
        items: tickers,
        updatedLast: DateTime.now(),
        isPublic: tickerProvider.isPublic));
  }
}

void showInfo(BuildContext context, TickerTileModel data) {}
