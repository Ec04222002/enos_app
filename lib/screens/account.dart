// account page
import 'package:enos/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
      ),
    );
  }
}
