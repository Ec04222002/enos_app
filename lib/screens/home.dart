//watchlist page
import 'package:enos/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  //const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ElevatedButton(
          child: Text("Log out"),
          onPressed: () async {
            if (context.read<GoogleSignInProvider>().user != null) {
              context.read<GoogleSignInProvider>().googleLogOut();
            }
            context.read<AuthService>().signOut();
          }),
    ));
  }
}
