import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:enos/constants.dart';

class Utils {
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  void showSnackBar(BuildContext context, String text) =>
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));

  void showTopBar(BuildContext context, String text) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      message: text,
      isDismissible: true,
      duration: Duration(seconds: 3),
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundColor: kDarkBackgroundColor,
    )..show(context);
  }

  static DateTime toDateTime(Timestamp value) {
    if (value == null) return null;

    return value.toDate();
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }

  static bool isMarketTime() {
    Map<String, List<String>> marketOpenTimes = {
      "pst": ["06:30AM", "01:00PM"],
      "mst": ["07:30AM", "02:00PM"],
      "cst": ["08:30AM", "03:00PM"],
      "est": ["09:30AM", "04:00PM"],
    };
    switch (DateTime.now().timeZoneName.toLowerCase()) {
      case "pst":
      case "pacific standard time":
      case "pdt":
      case "pacific daylight time":
        return checkTimeInRange(times: marketOpenTimes['pst']);
      case "mst":
      case "mountain standard time":
      case "mdt":
      case "mountain daylight time":
        return checkTimeInRange(times: marketOpenTimes['mst']);
      case "cst":
      case "central standard time":
      case "cdt":
      case "central daylight time":
        return checkTimeInRange(times: marketOpenTimes['cst']);
      case "est":
      case "eastern standard time":
      case "edt":
      case "eastern daylight time":
        return checkTimeInRange(times: marketOpenTimes['est']);
    }
  }

  static bool isPastPostMarket() {
    Map<String, List<String>> marketPostTimes = {
      "pst": ["05:00PM", "06:30PM"],
      "mst": ["06:00PM", "07:30PM"],
      "cst": ["07:00PM", "08:30AM"],
      "est": ["08:00PM", "09:30AM"],
    };
    switch (DateTime.now().timeZoneName.toLowerCase()) {
      case "pst":
      case "pacific standard time":
      case "pdt":
      case "pacific daylight time":
        return checkTimeInRange(times: marketPostTimes['pst']);
      case "mst":
      case "mountain standard time":
      case "mdt":
      case "mountain daylight time":
        return checkTimeInRange(times: marketPostTimes['mst']);
      case "cst":
      case "central standard time":
      case "cdt":
      case "central daylight time":
        return checkTimeInRange(times: marketPostTimes['cst']);
      case "est":
      case "eastern standard time":
      case "edt":
      case "eastern daylight time":
        return checkTimeInRange(times: marketPostTimes['est']);
    }
  }

  static bool checkTimeInRange(
      {String openTime, String closedTime, List<String> times}) {
    //NOTE: Time should be as given format only
    //10:00PM
    //10:00AM

    // 01:60PM ->13:60
    //Hrs:Min
    //if AM then its ok but if PM then? 12+time (12+10=22)
    if (times != null) {
      openTime = times[0];
      closedTime = times[0];
    }
    TimeOfDay timeNow = TimeOfDay.now();
    String openHr = openTime.substring(0, 2);
    String openMin = openTime.substring(3, 5);
    String openAmPm = openTime.substring(5);
    TimeOfDay timeOpen;
    if (openAmPm == "AM") {
      //am case
      if (openHr == "12") {
        //if 12AM then time is 00
        timeOpen = TimeOfDay(hour: 00, minute: int.parse(openMin));
      } else {
        timeOpen =
            TimeOfDay(hour: int.parse(openHr), minute: int.parse(openMin));
      }
    } else {
      //pm case
      if (openHr == "12") {
//if 12PM means as it is
        timeOpen =
            TimeOfDay(hour: int.parse(openHr), minute: int.parse(openMin));
      } else {
//add +12 to conv time to 24hr format
        timeOpen =
            TimeOfDay(hour: int.parse(openHr) + 12, minute: int.parse(openMin));
      }
    }

    String closeHr = closedTime.substring(0, 2);
    String closeMin = closedTime.substring(3, 5);
    String closeAmPm = closedTime.substring(5);

    TimeOfDay timeClose;

    if (closeAmPm == "AM") {
      //am case
      if (closeHr == "12") {
        timeClose = TimeOfDay(hour: 0, minute: int.parse(closeMin));
      } else {
        timeClose =
            TimeOfDay(hour: int.parse(closeHr), minute: int.parse(closeMin));
      }
    } else {
      //pm case
      if (closeHr == "12") {
        timeClose =
            TimeOfDay(hour: int.parse(closeHr), minute: int.parse(closeMin));
      } else {
        timeClose = TimeOfDay(
            hour: int.parse(closeHr) + 12, minute: int.parse(closeMin));
      }
    }

    int nowInMinutes = timeNow.hour * 60 + timeNow.minute;
    int openTimeInMinutes = timeOpen.hour * 60 + timeOpen.minute;
    int closeTimeInMinutes = timeClose.hour * 60 + timeClose.minute;

//handling day change ie pm to am
    if ((closeTimeInMinutes - openTimeInMinutes) < 0) {
      closeTimeInMinutes = closeTimeInMinutes + 1440;
      if (nowInMinutes >= 0 && nowInMinutes < openTimeInMinutes) {
        nowInMinutes = nowInMinutes + 1440;
      }
      if (openTimeInMinutes < nowInMinutes &&
          nowInMinutes < closeTimeInMinutes) {
        return true;
      }
    } else if (openTimeInMinutes < nowInMinutes &&
        nowInMinutes < closeTimeInMinutes) {
      return true;
    }

    return false;
  }
}
