import 'package:enos/models/nft_ticker.dart';
import 'package:enos/models/stock_ticker.dart';
import 'package:enos/models/user.dart';
import 'package:enos/widgets/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enos/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth;
  AuthService(this._auth);

  Stream<StockTicker> get stockTicker {}
  Stream<NftTicker> get nftTicker {}

  //missing more user data
  // UserModel _userFromFirebaseuser(dynamic user) {
  //   return user != null ? UserModel(uid: user.uid) : null;
  // }

  Stream<User> get authChanges {
    return _auth.authStateChanges();
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
      //init database
      //convert user to custom model
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
      print("S0");
      final googleUser = await googleSignIn.signIn();
      print("S1");
      if (googleUser == null) return null;
      print("S2");
      _user = googleUser;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      notifyListeners();
      return "Success";
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future googleLogOut() async {
    await googleSignIn.disconnect();
  }
}
