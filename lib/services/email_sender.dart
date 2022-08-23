import 'dart:async';
import 'dart:convert';
import 'package:enos/constants.dart';
import 'package:enos/services/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class EmailSender {
  // for sending request view
  final teamId = "service_i5jh1k6";
  // for sending request service
  final requestId = 'service_yoax69h';

  //request view temp
  final requestViewTempId = 'template_er7xvr8';
  //request service temp
  final requestServiceTempId = 'template_1lrwcuf';
  final userId = 'G0ltw4e2-s3hKUWLA';
  final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
  Future sendServiceRequest(
      {@required String name,
      @required String email,
      @required String subject,
      @required String message,
      @required BuildContext context}) async {
    if (message.trim().isEmpty) {
      return "Empty Message";
    }
    final response = await http.post(url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': requestId,
          'template_id': requestServiceTempId,
          'user_id': userId,
          'template_params': {
            "user_subject": subject,
            'from_name': name,
            'message': message,
            'user_email': email,
          }
        }));
    //print(response.statusCode);
    Utils util = Utils();
    if (response.statusCode == 200) {
      util.showSnackBar(context, "Sent Successfully 🎉", false);
    } else {
      util.showSnackBar(context, "Failed to Send", false, color: kRedColor);
    }

    Timer(Duration(milliseconds: 1500), () {
      util.removeSnackBar();
    });
    return;
  }

  Future sendRequestView(
      {@required String toName,
      @required String fromName,
      @required String fromEmail,
      @required String toEmail,
      @required BuildContext context}) async {
    if (toEmail == null || toEmail.isEmpty) {
      return "To Email is null";
    }
    print("sending request");
    final response = await http.post(url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': teamId,
          'template_id': requestViewTempId,
          'user_id': userId,
          'template_params': {
            "user_subject": "Enos App - Request View",
            'from_name': fromName,
            'to_name': toName,
            'to_email': toEmail,
            'from_email': fromEmail,
          }
        }));
    Utils util = Utils();
    if (response.statusCode == 200) {
      util.showSnackBar(context, "Sent Successfully 🎉", false);
    } else {
      util.showSnackBar(context, "Failed to Send", false, color: kRedColor);
    }

    Timer(Duration(milliseconds: 1500), () {
      util.removeSnackBar();
    });

    return;
  }
}
