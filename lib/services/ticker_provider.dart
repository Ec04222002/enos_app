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

  YahooApi yahooApi = YahooApi();
  bool toggle = false;
  List<int> times = [1, 3];

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
      print("getting data for $symbol");
      // _futureTickers.add(futureData);

      TickerTileModel data = await yahooApi.get(
          init: true,
          endpoint: "stock/v2/get-summary",
          query: {"symbol": symbol.toString(), "region": "US"});
      _symbols.add(symbol.toString());
      _tickers.add(data);
    }
    print("completed getting all ticker data");
  }

  Stream<TickerTileModel> getTileStream(String symbol) {
    int time = toggle ? times[0] : times[1];
    toggle = !toggle;
    return Stream.periodic(Duration(seconds: time)).asyncMap((_) {
      return getTileData(symbol);
    });
  }

  Future<TickerTileModel> getTileData(String symbol) async {
    TickerTileModel data = _tickers[_symbols.indexOf(symbol)];
    if (!Utils.isMarketTime() && !data.isLive) {
      print("$symbol not calling");
      return data;
    }
    print("$symbol is calling");
    data = await YahooApi().get(
        endpoint: "stock/v2/get-summary",
        query: {"symbol": symbol, "region": "US"});
    print(data.price);
    return data;
  }
}
