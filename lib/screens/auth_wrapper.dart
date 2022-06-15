//determines if user already logged in and show
//signup or home accordingly

import 'package:enos/models/user.dart';
import 'package:enos/screens/nav_display.dart';
import 'package:enos/screens/sign_in.dart';
import 'package:enos/services/auth.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  //const AuthWrapper({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserField>();
    if (user != null) {
      Navigator.popUntil(
        context,
        ModalRoute.withName('/'),
      );
      return NavDisplayScreen(uid: user.userUid);
    }
    return SignInPage();
  }
}
