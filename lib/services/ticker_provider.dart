import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/util.dart';
import 'package:enos/services/yahoo_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:flutter/material.dart';

// //run firebase methods to update tickers for watchlist
// // access list of tickers
class TickerTileProvider extends ChangeNotifier {
  String watchListUid;
  List<TickerTileModel> _tickers = [];
  List<String> _symbols = [];
  bool isPublic = false;
  bool isLive = false;
  Timer _timer;
  YahooApi yahooApi = YahooApi();
  bool toggle = false;
  List<int> times = [1, 2];

  TickerTileProvider({this.watchListUid});
  // List<Future<TickerTileModel>> get futureTickers => _futureTickers;
  List<TickerTileModel> get tickers => _tickers;
  List<String> get symbols => _symbols;

  // Future<TickerTileModel> futureTickerAt(int index) => _futureTickers[index];
  TickerTileModel tickerAt(int index) => _tickers[index];
  String symbolAt(int index) => _symbols[index];

  void setUid(String uid) {
    this.watchListUid = uid;
  }

  void setTickers(List<TickerTileModel> tickers) {
    _tickers = tickers;
  }

  void replaceTickerAt(int index, TickerTileModel replacement) {
    _tickers[index] = replacement;
    _symbols[index] = replacement.symbol;
  }

  void moveTicker(int startIndex, int endIndex) {
    if (startIndex < endIndex) {
      endIndex -= 1;
    }
    final TickerTileModel ticker = tickers.removeAt(startIndex);
    final String symbol = symbols.removeAt(startIndex);
    _tickers.insert(endIndex, ticker);
    _symbols.insert(endIndex, symbol);
  }

  void removeTicker(int index) {
    _tickers.removeAt(index);
    // _futureTickers.removeAt(index);
    _symbols.removeAt(index);
    notifyListeners();
  }

  Future<void> setAllInitData() async {
    DocumentSnapshot watchListDoc =
        await FirebaseApi.getWatchListDoc(watchListUid);

    isPublic = watchListDoc['is_public'];
    List<dynamic> tickers = watchListDoc['items'];
    print("setting all init");
    for (var symbol in tickers) {
      // print("getting data for $symbol");
      // _futureTickers.add(futureData);

      TickerTileModel data =
          await yahooApi.get(symbol: symbol.toString(), requestChartData: true);
      _symbols.add(symbol.toString());
      _tickers.add(data);
    }
    print("completed getting all ticker data");
  }

  Stream<TickerTileModel> getTileStream(String symbol) {
    int time = toggle ? times[0] : times[1];
    toggle = !toggle;
    int counter = 0;
    return Stream.periodic(Duration(seconds: time)).asyncMap((_) {
      counter++;
      print("Counting $counter");
      if (counter % 5 == 0) {
        return getTileData(symbol, true);
      }
      return getTileData(symbol, false);
    });
  }

  Future<TickerTileModel> getTileData(
      String symbol, bool requestChartData) async {
    TickerTileModel data = _tickers[_symbols.indexOf(symbol)];
    if (!Utils.isMarketTime() && !data.isLive ||
        (!data.isCrypto && Utils.isWeekend())) {
      print("$symbol not calling");
      return data;
    }
    print("$symbol is calling");
    bool readChartData = false;
    if (Utils.isMarketTime() && requestChartData) {
      readChartData = true;
    }
    data = await yahooApi.get(
        symbol: symbol, lastData: data, requestChartData: readChartData);
    //print(data.price);
    return data;
  }
}
