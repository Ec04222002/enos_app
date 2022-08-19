import 'dart:async';

import 'package:enos/constants.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/email_sender.dart';
import 'package:enos/services/util.dart';
import 'package:flutter/material.dart';

class MessageRequest extends StatelessWidget {
  const MessageRequest({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 22,
        onPressed: () {},
        icon: Icon(
          Icons.arrow_forward_ios_outlined,
          color: kDarkTextColor,
        ));
  }

  static openMessenger(BuildContext context, UserModel self) {
    List<Map<String, dynamic>> subjectBtns = [
      {
        "text": "Bugs/Error",
        "icon": Icons.bug_report_outlined,
        "email_subject": "Bugs",
        'active': false
      },
      {
        "text": "Recommend Features",
        "icon": Icons.stars_outlined,
        "email_subject": "Recommending features",
        'active': false
      },
      {
        "text": "Report User",
        "icon": Icons.face_sharp,
        "email_subject": "Reporting user",
        'active': false
      },
      {
        "text": "Business",
        "icon": Icons.business_center_rounded,
        "email_subject": "Business",
        'active': false
      },
      {
        "text": "Other",
        "icon": Icons.question_mark_outlined,
        "email_subject": "Other",
        'active': false
      }
    ];
    ValueNotifier toggleBtns = ValueNotifier(false);
    final _formKey = GlobalKey<FormState>();
    String btnText = "Send";
    Color btnColor = kActiveColor;
    String activeBtnValue = '';
    final myController = TextEditingController();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GestureDetector(
                  onTap: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  },
                  child: Scaffold(
                    appBar: AppBar(
                        backgroundColor: kLightBackgroundColor,
                        centerTitle: true,
                        title: Text(
                          "Message Request",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        leading: IconButton(
                          color: kDarkTextColor.withOpacity(0.9),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios),
                        )),
                    body: ValueListenableBuilder(
                      valueListenable: toggleBtns,
                      builder: (context, value, child) => SingleChildScrollView(
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Wrap(
                                children: List.generate(
                                    subjectBtns.length,
                                    (index) => Container(
                                          padding: EdgeInsets.zero,
                                          margin:
                                              EdgeInsets.fromLTRB(8, 10, 0, 0),
                                          // color: subjectBtns[index]['active']
                                          //     ? kActiveColor
                                          //     : kLightBackgroundColor,
                                          child: TextButton.icon(
                                            style: ButtonStyle(
                                                backgroundColor: subjectBtns[
                                                        index]['active']
                                                    ? MaterialStateProperty.all<
                                                        Color>(kActiveColor)
                                                    : MaterialStateProperty.all<
                                                            Color>(
                                                        kLightBackgroundColor),
                                                shape: MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ))),
                                            onPressed: () {
                                              if (!subjectBtns[index]
                                                  ['active']) {
                                                subjectBtns.forEach((element) {
                                                  element['active'] = false;
                                                });
                                                subjectBtns[index]['active'] =
                                                    true;
                                                activeBtnValue =
                                                    subjectBtns[index]['value'];
                                                toggleBtns.value =
                                                    !toggleBtns.value;
                                              }
                                            },
                                            label: Text(
                                              subjectBtns[index]['text'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: subjectBtns[index]
                                                          ['active']
                                                      ? kDarkBackgroundColor
                                                      : Utils.lighten(
                                                          kActiveColor)),
                                            ),
                                            icon: Icon(
                                                subjectBtns[index]['icon'],
                                                color: subjectBtns[index]
                                                        ['active']
                                                    ? kDarkBackgroundColor
                                                    : Utils.lighten(
                                                        kActiveColor)),
                                          ),
                                        )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: myController,
                                        decoration: InputDecoration(
                                            counterStyle: TextStyle(
                                                color: kBrightTextColor),
                                            filled: true,
                                            fillColor: kLightBackgroundColor,
                                            hintStyle: TextStyle(
                                                color: kDisabledColor),
                                            hintText: 'Your message here',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            )),
                                        style: TextStyle(color: kDarkTextColor),
                                        maxLines: 14,
                                        // The validator receives the text that the user has entered.
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty ||
                                              value.trim().split(" ").length <
                                                  3) {
                                            return 'Please enter a minimium of 2 words';
                                          }
                                          return null;
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: btnColor),
                                          onPressed: () {
                                            Utils util = Utils();

                                            // Validate returns true if the form is valid, or false otherwise.
                                            if (!_formKey.currentState
                                                .validate()) {
                                              // util.showSnackBar(
                                              //     context,
                                              //     "Error - Message Invalid",
                                              //     false,
                                              //     color: kRedColor);
                                              // Timer(
                                              //     Duration(milliseconds: 1700),
                                              //     () {
                                              //   util.removeSnackBar();
                                              // });
                                              return;
                                            }
                                            if (subjectBtns.every((element) =>
                                                element['active'] == false)) {
                                              util.showSnackBar(
                                                  context,
                                                  "Error - Please select a subject button",
                                                  false,
                                                  color: kRedColor);
                                              Timer(
                                                  Duration(milliseconds: 2500),
                                                  () {
                                                util.removeSnackBar();
                                              });
                                              return;
                                            }

                                            if (btnText == "Submitted") return;
                                            // If the form is valid, display a snackbar. In the real world,
                                            // you'd often call a server or save the information in a database.
                                            EmailSender().sendServiceRequest(
                                                name: self.username,
                                                email: self.email,
                                                subject: activeBtnValue,
                                                message: myController.text,
                                                context: context);
                                            btnText = "Submitted";
                                            btnColor = kDisabledColor;
                                            toggleBtns.value =
                                                !toggleBtns.value;
                                          },
                                          child: Text(btnText),
                                        ),
                                      ),
                                    ],
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )));
  }
}
