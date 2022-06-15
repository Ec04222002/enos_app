import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/models/watchlist.dart';
import 'package:enos/models/comment.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/widgets/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enos/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth;
  //not used
  UserModel user;
  AuthService(this._auth);
  //future? of comments // for future builder for comment section
  //stream of watchlist // for stream builder for watchlist

  UserField _userFromFirebaseUser(dynamic user) {
    return user != null ? UserField(userUid: user.uid) : null;
  }

  Stream<UserField> get authChanges {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future resetPassword({String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Success";
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future signInWithEmailAndPassword({String email, String password}) async {
    try {
      dynamic result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      dynamic user = result.user;
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword({String email, String password}) async {
    try {
      dynamic result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      dynamic user = result.user;
      FirebaseApi.updateUserData(UserModel(
        userUid: user.uid,
        createdTime: DateTime.now(),
        username: user.email,
        metrics: List.filled(22, true),
      ));
      FirebaseApi.updateWatchList(Watchlist(
        watchlistUid: user.uid,
        items: defaultTickerTileModels,
        updatedLast: DateTime.now(),
      ));
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount _user;

  GoogleSignInAccount get user => _user;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      _user = googleUser;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      //default
      FirebaseApi.updateUserData(UserModel(
        userUid: _user.id,
        createdTime: DateTime.now(),
        username: _user.email,
        metrics: List.filled(22, true),
      ));
      FirebaseApi.updateWatchList(Watchlist(
        watchlistUid: _user.id,
        items: defaultTickerTileModels,
        updatedLast: DateTime.now(),
      ));
      notifyListeners();
      return _user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future googleLogOut() async {
    await googleSignIn.disconnect();
  }
}
