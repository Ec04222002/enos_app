import 'package:enos/constants.dart';
import 'package:enos/services/auth.dart';
import 'package:enos/widgets/auth_button.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/text_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  //const ResetPasswordScreen({Key key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailTextController = TextEditingController();

  String error = '';
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _emailTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text('Reset Password',
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
                      Text(
                        error,
                        style: TextStyle(color: kRedColor),
                      ),
                      AuthButton(
                        backgroundColor: kActiveColor,
                        textColor: kDarkTextColor,
                        text: "Reset Password",
                        onTap: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              isLoading = true;
                              //print("Showing loading");
                            });
                            dynamic result = await context
                                .read<AuthService>()
                                .resetPassword(
                                    email: _emailTextController.text.trim());

                            if (result == null) {
                              setState(() {
                                isLoading = false;
                                error = "Please enter a valid email";
                              });
                            } else {
                              Navigator.of(context).pop();
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
