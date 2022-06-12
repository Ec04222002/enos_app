import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/models/user.dart';
import 'package:enos/models/watchlist.dart';
import 'package:enos/widgets/ticker_tile.dart';
import 'package:enos/services/util.dart';

//access data from yahoo data base
//access data & stream from firestore

class FirebaseApi {
  //transform the list into stream

  static List<TickerTileModel> _tickerDataFromSnapshot(
      DocumentSnapshot snapshot) {
    dynamic tickers = snapshot.get('items');
    List<TickerTileModel> newTickers = [];
    //creating list of ticker models from snapshot
    for (var i = 0; i < tickers.length; ++i) {
      dynamic ticker = tickers[i];
      newTickers.add(TickerTileModel(
        tickerName: ticker['ticker_name'],
        isNft: ticker['is_nft'],
        // companyName: ticker['company_name'],
        // price: ticker['price'],
        // percentChange: ticker['percent_change'],
      ));
    }
    return newTickers;
  }

  static Stream<List<TickerTileModel>> watchlistTickers(String watchListUid) {
    try {
      Stream<List<TickerTileModel>> watchListStream = FirebaseFirestore.instance
          .collection('Watchlists')
          .doc(watchListUid)
          .snapshots()
          .map(_tickerDataFromSnapshot);
      return watchListStream;
    } catch (error) {
      print("watchlist doesn't exist");
      return null;
    }
  }

  static Future<void> updateUserData(UserModel data) async {
    // print("update user: ${data}");
    final userDoc = await FirebaseFirestore.instance.collection('Users').doc();
    await userDoc.set(data.toJson());
    print('finished setting user');
    return;
  }

  static Future<void> updateWatchList(Watchlist list) async {
    // print("updating watchlist:${list}");
    // print(list.watchlistUid);
    final watchListDoc = FirebaseFirestore.instance
        .collection('Watchlists')
        .doc(list.watchlistUid);
    print("watchlist ${watchListDoc}");
    await watchListDoc.set(list.toJson());
    return;
  }

  static Future<bool> isUserExist(userUid) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('Users');
      var doc = await collectionRef.doc(userUid).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }
}
