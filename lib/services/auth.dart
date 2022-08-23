import 'package:enos/models/watchlist.dart';

import 'package:enos/models/user.dart';
import 'package:enos/services/firebase_api.dart';

import 'package:enos/widgets/profile_pic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enos/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth;
  //not used
  UserModel _user;
  AuthService(this._auth);
  //future? of comments // for future builder for comment section
  //stream of watchlist // for stream builder for watchlist

  UserModel get userModel => _user;
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
      //print(error.toString());
      return null;
    }
  }

  Future<void> setUser(String uid) async {
    _user = await FirebaseApi.getUser(uid);
  }

  Future signInWithEmailAndPassword({String email, String password}) async {
    try {
      //print("trying to sign in");
      dynamic result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // User user = result.user;
      // await setUser(user.uid);
      return result;
    } catch (error) {
      //print(error.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword(
      {String email, String password, String userName}) async {
    try {
      dynamic result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      user.updateDisplayName(userName);
      // //print("result: ${result}");
      // //print("user: ${user}");
      _user = UserModel(
        email: user.email,
        userUid: user.uid,
        createdTime: DateTime.now(),
        username: userName,
        userSaved: [],
        comments: [],
        likedComments: [],
        metrics: List.filled(11, true) + List.filled(12, false),
        profileBgColor: ProfilePicture.getRandomColor(),
        profileBorderColor: ProfilePicture.getRandomColor(),
      );
      await FirebaseApi.updateUserData(_user);
      await FirebaseApi.updateWatchList(Watchlist(
        watchlistUid: user.uid,
        items: defaultTickerTileModels,
        updatedLast: DateTime.now(),
      ));
      return user;
    } catch (error) {
      //print(error.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      //print(error.toString());
      return null;
    }
  }
}

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  UserModel _user;

  UserModel get user => _user;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      dynamic result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      //checking if user exists
      User u = result.user;
      bool userExist = await FirebaseApi.checkExist('Users', u.uid);
      if (userExist) {
        //print("user exists");
        _user = await FirebaseApi.getUser(u.uid);
      } else {
        //print('user does not exists');
        String userName = u.email.substring(0, u.email.indexOf("@"));
        if (userName.length > 14) {
          userName = userName.substring(0, 14);
        }
        _user = UserModel(
          email: u.email,
          userUid: u.uid,
          createdTime: DateTime.now(),
          username: userName,
          metrics: List.filled(11, true) + List.filled(12, false),
          comments: [],
          likedComments: [],
          userSaved: [],
          profileBgColor: ProfilePicture.getRandomColor(),
          profileBorderColor: ProfilePicture.getRandomColor(),
        );
        //default
        await FirebaseApi.updateUserData(_user);
        await FirebaseApi.updateWatchList(Watchlist(
          isPublic: true,
          watchlistUid: _user.userUid,
          items: defaultTickerTileModels,
          updatedLast: DateTime.now(),
        ));
      }

      notifyListeners();
      return _user;
    } catch (error) {
      //print(error.toString());
      return null;
    }
  }

  Future googleLogOut() async {
    await googleSignIn.disconnect();
  }
}
