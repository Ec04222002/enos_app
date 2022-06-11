import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/models/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:flutter/material.dart';

//run firebase methods to update tickers for watchlist
// access list of tickers
class TickerTileProvider extends ChangeNotifier {
  String watchListUid;
  List<TickerTileModel> _tickers;
  UserModel user;
  TickerTileProvider({this.watchListUid});

  List<TickerTileModel> get tickers => _tickers;

  void setTickers({List<TickerTileModel> tickers}) {
    _tickers = tickers;
  }

  void readTickers() {}
  //add tickerModel to stream

  //remove tickerModel ftom stream
}
