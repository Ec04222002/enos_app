//determines if user already logged in and show
//signup or home accordingly

import 'package:enos/screens/nav_display.dart';
import 'package:enos/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  //const AuthWrapper({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    if (firebaseUser != null) {
      Navigator.popUntil(
        context,
        ModalRoute.withName('/'),
      );
      return NavDisplayScreen();
    }
    return SignInPage();
  }
}
