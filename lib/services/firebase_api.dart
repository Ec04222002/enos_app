import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/services/yahoo_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/models/user.dart';
import 'package:enos/models/watchlist.dart';
import 'package:enos/widgets/ticker_tile.dart';
import 'package:enos/services/util.dart';
import 'package:provider/provider.dart';

//access data from yahoo data base
//access data & stream from firestore

class FirebaseApi {
  static List<String> _tickerDataFromSnapshot(DocumentSnapshot snapshot) {
    List<dynamic> tickers = snapshot.get('items');
    List<String> newTickers = tickers.map((e) => e.toString()).toList();
    print("converting to ${newTickers}");
    return newTickers;
  }

  static Stream<List<String>> watchlistTickers(String watchListUid) {
    try {
      Stream<List<String>> watchListStream = FirebaseFirestore.instance
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

  static Future<UserModel> getUser(String uid) async {
    final user =
        await FirebaseFirestore.instance.collection("Users").doc(uid).get();
    return UserModel.fromJson(user.data());
  }

  static Future<List<UserModel>> getAllUser() async {
    List<UserModel> listUsers = [];
    final userDocs = await FirebaseFirestore.instance.collection('Users').get();
    userDocs.docs.map((doc) {
      listUsers.add(UserModel.fromJson(doc.data()));
    });
    return listUsers;
  }

  static Future<void> updateUserData(UserModel data) async {
    final userDoc = await FirebaseFirestore.instance.collection('Users').doc();
    await userDoc.set(data.toJson());
    print('finished setting user');
    return;
  }

  static Future<void> updateWatchList(Watchlist list) async {
    final watchListDoc = await FirebaseFirestore.instance
        .collection('Watchlists')
        .doc(list.watchlistUid);

    await watchListDoc.set(list.toJson());
    return;
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getWatchListDoc(
      String watchListUid) async {
    try {
      final watchListStream = await FirebaseFirestore.instance
          .collection('Watchlists')
          .doc(watchListUid)
          .get();
      return watchListStream;
    } catch (error) {
      print("watchlist doesn't exist");
      return null;
    }
  }
}
