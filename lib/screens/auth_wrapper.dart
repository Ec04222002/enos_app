//determines if user already logged in and show
//signup or home accordingly

import 'package:enos/screens/sign_in.dart';
import 'package:enos/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  //const AuthWrapper({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    print("in wrapper: rebuilding");
    if (firebaseUser != null) {
      print("Showing Home Page");
      Navigator.popUntil(
        context,
        ModalRoute.withName('/'),
      );
      return HomePage();
    }
    print("Showing Sign in page");
    return SignInPage();
  }
}
