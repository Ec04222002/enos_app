import 'package:enos/constants.dart';
import 'package:enos/services/auth.dart';
import 'package:enos/widgets/auth_button.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/text_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final Function toggleView;

  const RegisterPage({Key key, this.toggleView}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _userNameTextController = TextEditingController();
  String error = '';
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _emailTextController.dispose();
    _passwordTextController.dispose();
    _userNameTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading(
            loadText: "Registering ...",
          )
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text('Sign Up',
                  style: Theme.of(context)
                      .textTheme
                      .headline1
                      .copyWith(fontSize: 22.0)),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).size.height * 0.15, 20, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextInputWidget(
                          text: "Enter username",
                          icon: Icons.person_outline,
                          isPassword: false,
                          validatorFunct: (val) => val.length < 6
                              ? 'Please enter an username 6+ chars long'
                              : null,
                          obscureText: false,
                          controller: _userNameTextController),
                      SizedBox(height: 15),
                      TextInputWidget(
                          text: "Enter email",
                          icon: Icons.email_outlined,
                          isPassword: false,
                          validatorFunct: (val) =>
                              val.isEmpty ? 'Please enter an email' : null,
                          obscureText: false,
                          controller: _emailTextController),
                      SizedBox(height: 15),
                      TextInputWidget(
                          text: "Enter password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validatorFunct: (val) => val.length < 6
                              ? 'Please enter a password 6+ chars long'
                              : null,
                          controller: _passwordTextController),
                      SizedBox(height: 15),
                      Text(
                        error,
                        style: TextStyle(color: kRedColor),
                      ),
                      AuthButton(
                        backgroundColor: kActiveColor,
                        textColor: kDarkTextColor,
                        text: "Sign up ",
                        onTap: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              isLoading = true;
                              //print("show loading");
                            });
                            dynamic result = await context
                                .read<AuthService>()
                                .registerWithEmailAndPassword(
                                    email: _emailTextController.text.trim(),
                                    password:
                                        _passwordTextController.text.trim());
                            print("registered");
                            if (result == null) {
                              setState(() {
                                isLoading = false;
                                error = 'Please enter a valid email';
                              });
                              return;
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
