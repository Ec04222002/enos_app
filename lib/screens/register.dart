import 'package:enos/constants.dart';
import 'package:enos/services/auth.dart';
import 'package:enos/widgets/auth_button.dart';
import 'package:enos/widgets/text_input_widget.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  //const RegisterPage({ Key? key }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _userNameTextController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailTextController.dispose();
    _passwordTextController.dispose();
    _userNameTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Sign Up',
            style:
                Theme.of(context).textTheme.headline1.copyWith(fontSize: 22.0)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).size.height * 0.15, 20, 0),
          child: Column(
            children: <Widget>[
              TextInputWidget(
                  text: "Enter username",
                  icon: Icons.person_outline,
                  isPassword: false,
                  controller: _emailTextController),
              SizedBox(height: 20),
              TextInputWidget(
                  text: "Enter email",
                  icon: Icons.email_outlined,
                  isPassword: false,
                  controller: _emailTextController),
              SizedBox(height: 20),
              TextInputWidget(
                  text: "Enter password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordTextController),
              SizedBox(height: 20),
              AuthButton(
                backgroundColor: kActiveColor,
                textColor: kDarkTextColor,
                text: "Sign up ",
                onTap: () => {
                  AuthService().registerWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text)
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
