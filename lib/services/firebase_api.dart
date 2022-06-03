import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/models/watchlist.dart';
import 'package:enos/widgets/ticker_tile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:enos/services/util.dart';

//access data from yahoo data base
//access data & stream from firestore

class FirebaseApi {
  //transform the list into stream
  static Stream<List<TickerTileModel>> watchlistTickers(String watchListUid) {
    Stream watchListStream = FirebaseFirestore.instance
        .collection("Watchlists")
        .doc(watchListUid)
        .snapshots()
        .transform(Utils.transformer(Watchlist.fromJson));
    return watchListStream;
  }
}
