  import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/models/comment.dart';
import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/services/ticker_page_info.dart';
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

  static Future<Comment> getComment(String uid) async{
    final comment =
        await FirebaseFirestore.instance.collection("Comments").doc(uid).get();
    return Comment.fromJson(comment.data());
  }

  static Future<String> updateComment(Comment comment) async{
    final com =
        await FirebaseFirestore.instance.collection("Comments").doc(comment.commentUid);
    comment.commentUid = com.id;
    await com.set(comment.toJson());
    return com.id;
  }

  static Future<List<Comment>> getStockComment(String symbol) async{
    List<Comment> ret = [];
    final comments = await FirebaseFirestore.instance.collection("Comments").get();
    comments.docs.forEach((doc) {
      String stockId = doc.data()['stock_uid'].toString();
      bool nested = doc.data()['isNested'];
      if(stockId == symbol && !nested) {
        ret.add(Comment.fromJson(doc.data()));
      }
    });
    return ret;
  }

  static Future<List<UserModel>> getAllUser({String searchQuery}) async {
    List<UserModel> listUsers = [];
    final userDocs = await FirebaseFirestore.instance.collection('Users').get();
    userDocs.docs.forEach((doc) {
      String userName = doc.data()['username'].toString().toLowerCase();
      if (userName.startsWith(searchQuery.toLowerCase())) {
        listUsers.add(UserModel.fromJson(doc.data()));
      }
      print(doc);
    });
    print(listUsers);
    return listUsers;
  }

  static Future<void> updateUserData(UserModel data) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(data.userUid);
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

  static Future<bool> checkExist(String collection, String docID) async {
    bool exist;
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(docID)
          .get()
          .then((doc) {
        exist = doc.exists;
        print("Exist: $exist");
      });
      return exist;
    } catch (e) {
      // If any error
      return false;
    }
  }
}
