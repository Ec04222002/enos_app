import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/constants.dart';
import 'package:enos/models/search_tile.dart';
import 'package:enos/models/user.dart';
import 'package:enos/models/watchlist.dart';
import 'package:enos/screens/home.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/util.dart';
import 'package:enos/services/yahoo_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:flutter/material.dart';

// //run firebase methods to update tickers for watchlist
// // access list of tickers
class TickerTileProvider extends ChangeNotifier {
  bool isLoading = false;
  String watchListUid;
  List<TickerTileModel> _tickers = [];
  List<String> _symbols = [];
  bool isPublic = true;
  bool isLive = false;
  DateTime lastUpdatedTime = DateTime.now();
  YahooApi yahooApi = YahooApi();
  bool toggle = false;
  List<int> times = [1, 2];
  //init recommendation

  Function loadFunct;
  List<SearchTile> _recs = [];

  TickerTileProvider({this.watchListUid});
  List<TickerTileModel> get tickers => _tickers;
  List<String> get symbols => _symbols;
  List<SearchTile> get recs => _recs;
  TickerTileModel tickerAt(int index) => _tickers[index];
  String symbolAt(int index) => _symbols[index];

  void setUid(String uid) {
    this.watchListUid = uid;
  }

  void setTickers(List<TickerTileModel> tickers) {
    _tickers = tickers;
  }

  void setRecs(List<SearchTile> recs) {
    _recs = recs;
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

  static Future<List<TickerTileModel>> getOtherTickers(String uid) async {
    dynamic watchListDoc = await FirebaseApi.getWatchListDoc(uid);
    List<String> otherSymbols =
        FirebaseApi.tickerDataFromSnapshot(watchListDoc);
    if (otherSymbols.isEmpty) return [];
    print("got other users symbols ${otherSymbols}");
    List<TickerTileModel> tickers =
        await YahooApi().getWatchlistUpdates(otherSymbols, false);
    return tickers;
  }

  Future<void> removeTicker(int index, {BuildContext, context}) async {
    isLoading = true;
    lastUpdatedTime = DateTime.now();
    _symbols.removeAt(index);
    _tickers.removeAt(index);
    await FirebaseApi.updateWatchList(Watchlist(
        watchlistUid: watchListUid,
        items: _symbols,
        updatedLast: lastUpdatedTime,
        isPublic: isPublic));
    isLoading = false;
    notifyListeners();
  }

  Future<void> addTicker(String symbol, {BuildContext context}) async {
    if (_symbols.length >= 10) {
      return;
    }
    isLoading = true;
    TickerTileModel data = await yahooApi.get(
        symbol: symbol.toString(),
        lastData: TickerTileModel(isSaved: true),
        requestChartData: true);
    _tickers.add(data);
    _symbols.add(symbol);
    lastUpdatedTime = DateTime.now();
    await FirebaseApi.updateWatchList(Watchlist(
        watchlistUid: watchListUid,
        items: _symbols,
        updatedLast: lastUpdatedTime,
        isPublic: isPublic));
    isLoading = false;

    notifyListeners();
  }

  Future<void> setAllInitData() async {
    //get watchlist
    print("WatchlistUid: $watchListUid");
    DocumentSnapshot watchListDoc =
        await FirebaseApi.getWatchListDoc(watchListUid);
    //set needed parameter
    try {
      isPublic = watchListDoc['is_public'];
      Timestamp time = watchListDoc['updated_last'];
      print(time);
      lastUpdatedTime = time.toDate();
      List<dynamic> tickers = watchListDoc['items'];
      //getting watchlist data from api
      tickers.forEach((element) {
        print("element: $element");
        _symbols.add(element.toString());
      });
    }
    //if error exists => google login is updating watchlist
    //or init login
    //=> set the default settings
    catch (e) {
      defaultTickerTileModels.forEach((element) {
        _symbols.add(element);
      });
    }
    setTickers(await yahooApi.getInitTickers(_symbols));
    //get list of recs for search
    this._recs = await yahooApi.getRecommendedStockList();
  }

  Stream<TickerTileModel> getTileStream(String symbol) {
    int time = toggle ? times[0] : times[1];
    toggle = !toggle;
    int counter = 0;
    return Stream.periodic(Duration(seconds: time)).asyncMap((_) {
      counter++;
      if (counter % 2 == 0) {
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
