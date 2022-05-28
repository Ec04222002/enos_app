//login page
import 'package:enos/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  //const SignInPage({ Key? key }) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // final SignInPage = TextEditingController();
  // final passwordController = TextEditingController();
  final isLoading = false;

  //final AuthService _auth = AuthService();
  // @override
  // void dispose() {
  //   SignInPage.dispose();
  //   passwordController.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            body: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor)),
          );
  }

  // Future signIn() async {
  //   await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: SignInPage.text.trim(),
  //       password: passwordController.text.trim());
  // }
}
