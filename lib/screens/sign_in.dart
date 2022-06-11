//login page
import 'package:enos/screens/register.dart';
import 'package:enos/screens/reset_password.dart';
import 'package:enos/services/auth.dart';
import 'package:enos/widgets/auth_button.dart';
import 'package:enos/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:enos/constants.dart';
import 'package:enos/widgets/text_input_widget.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  //const SignInPage({Key key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  bool isLoading = false;
  String error = '';
  final _formKey = GlobalKey<FormState>();
  //final AuthService _auth = AuthService();
  @override
  void dispose() {
    super.dispose();
    _emailTextController.dispose();
    _passwordTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            body: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.fromLTRB(
                  30, MediaQuery.of(context).size.height * 0.08, 30, 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Align(
                        child:
                            Image.asset('assets/launch_image.png', width: 120)),
                    Text(
                      "Welcome to Enos!",
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          .copyWith(letterSpacing: 0.5, fontSize: 25),
                    ),
                    SizedBox(height: 20),
                    TextInputWidget(
                      text: "Username or email",
                      icon: Icons.person_outline,
                      isPassword: false,
                      validatorFunct: (val) =>
                          val.isEmpty ? 'Please enter an email' : null,
                      controller: _emailTextController,
                      obscureText: false,
                    ),
                    SizedBox(height: 10),
                    TextInputWidget(
                      text: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validatorFunct: (val) => val.length < 6
                          ? 'Please enter a password 6+ chars long'
                          : null,
                      controller: _passwordTextController,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: 35,
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ResetPasswordScreen())),
                            child: Text(
                              "Forgot Password ?",
                              style:
                                  TextStyle(fontSize: 12, color: kActiveColor),
                              textAlign: TextAlign.right,
                            ))),
                    Text(
                      error,
                      style: TextStyle(color: kRedColor),
                    ),
                    AuthButton(
                      backgroundColor: kActiveColor,
                      text: 'Log in',
                      onTap: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            isLoading = true;
                            //print("Showing loading");
                          });
                          dynamic result = await context
                              .read<AuthService>()
                              .signInWithEmailAndPassword(
                                  email: _emailTextController.text.trim(),
                                  password:
                                      _passwordTextController.text.trim());
                          print("signed in");
                          if (result == null) {
                            setState(() {
                              isLoading = false;
                              //print("Error logging in");
                              error = 'Please enter a valid email';
                            });
                            return;
                          }
                          print("Signed in result: $result");
                          //setting created user for provider
                          context.read<AuthService>().setUser(result);
                          //print("completed");
                        }
                      },
                    ),
                    AuthButton(
                      textColor: Colors.black54,
                      backgroundColor: Colors.white,
                      leadIcon: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 9.0, horizontal: 10.0),
                          child: Image.network(
                              'https://developers.google.com/identity/images/g-logo.png')),
                      text: 'Sign in with Google',
                      onTap: () async {
                        final provider = Provider.of<GoogleSignInProvider>(
                            context,
                            listen: false);
                        setState(() {
                          isLoading = true;
                          //print("Showing loading");
                        });
                        dynamic result = await provider.googleLogin();
                        print("Signed in with google");
                        if (result == null) {
                          setState(() {
                            isLoading = false;
                            //print("Error logging in");
                            error =
                                'Google cannot log you in. Please try again later';
                          });
                        }
                        print("Google results: $result");
                        context.read<AuthService>().setUser(result);
                      },
                    ),
                    SizedBox(height: 15),
                    //google/fb
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have account? ",
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterPage()));
                            },
                            child: const Text('Sign up',
                                style: TextStyle(color: kActiveColor))),
                      ],
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            )),
          );
  }
}
