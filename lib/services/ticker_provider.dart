import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/firebase_api.dart';
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
  YahooApi yahooApi = YahooApi();
  //UserModel user;
  TickerTileProvider({this.watchListUid});

  List<TickerTileModel> get tickers => _tickers;
  List<String> get symbols => _symbols;
  void setUid(String uid) {
    this.watchListUid = uid;
  }

  void setTickers(List<TickerTileModel> tickers) {
    _tickers = tickers;
  }

  void moveTicker(int startIndex, int endIndex) {
    // print("Inital Symbols: ${_symbols}");
    // print("Initial Model: ${_tickers}");
    if (startIndex < endIndex) {
      endIndex -= 1;
    }
    final TickerTileModel ticker = tickers.removeAt(startIndex);
    final String symbol = symbols.removeAt(startIndex);
    tickers.insert(endIndex, ticker);
    symbols.insert(endIndex, symbol);
    // print("Final Symbols: ${_symbols}");
    // print("Final models: ${_tickers}");
    //notifyListeners();
  }

  void removeTicker(int index) {
    print("removing");
    _tickers.removeAt(index);
    notifyListeners();
  }

  Future<void> setAllInitData() async {
    DocumentSnapshot watchListDoc =
        await FirebaseApi.getWatchListDoc(watchListUid);

    isPublic = watchListDoc['is_public'];
    List<dynamic> tickers = watchListDoc['items'];

    for (var symbol in tickers) {
      TickerTileModel data = await yahooApi.get(
          endpoint: "stock/v2/get-summary",
          query: {"symbol": symbol.toString(), "region": "US"});
      _symbols.add(symbol.toString());
      _tickers.add(data);
    }
    print("completed getting all ticker data");
  }

  // void readTickers() {}
  // //add tickerModel to stream
  // void addTile(TickerTileModel tileData) => FirebaseApi.addTile(tileData);
  // void removeTile(TickerTileModel tileData) => FirebaseApi.removeTile(tileData);
  //remove tickerModel ftom stream
}
