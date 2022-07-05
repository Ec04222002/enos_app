import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:flutter/material.dart';
import 'package:enos/constants.dart';
import 'dart:math';

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

  static void showAlertDialog(BuildContext context, String content,
      Function cancelCallBack, Function confirmCallBack) {
    // set up the buttons
    List<Widget> actionBtns = [];

    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: cancelCallBack,
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed: confirmCallBack,
    );
    //ok alert
    if (confirmCallBack == null) {
      continueButton = TextButton(onPressed: cancelCallBack, child: Text("Ok"));
      actionBtns.add(continueButton);
    } else {
      actionBtns.add(cancelButton);
      actionBtns.add(continueButton);
    }
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(content),
      actions: actionBtns,
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void showSnackBar(BuildContext context, String text) =>
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          backgroundColor: kLightBackgroundColor,
          behavior: SnackBarBehavior.floating,
          content: Text(text),
          width: 145,
        ));

  static DateTime toDateTime(Timestamp value) {
    if (value == null) return null;

    return value.toDate();
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }

  static double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  static String fixNumToFormat(
      double num, bool isPercentage, bool isConstrain) {
    // double num = exp(number);
    // print("num = $num");
    String numAsString = num.toString();

    int decIndex = numAsString.indexOf(".");
    String preDecimal = numAsString.substring(0, decIndex);
    String postDecimal = numAsString.substring(decIndex + 1);

    // print("preDecimal: $preDecimal");
    // print("postDecimal: $postDecimal");
    // print(preDecimal.replaceAll("0", "").replaceAll("-", ""));
    //if number contains e- => number really small
    if (numAsString.contains("e-")) {
      return "-0.000";
    }
    if (isPercentage ||
        preDecimal.replaceAll("0", "").replaceAll("-", "").length > 0) {
      return num.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    }
    //for all 0. nums
    //find numbers until you find index 3 non-zero digits
    int index = 0;
    int pastConsZeroCount = 0;
    bool startCount = false;
    for (var i = 0; i < postDecimal.length; ++i) {
      if (isConstrain && i == 2) {
        index = i;
        break;
      }
      if (startCount) {
        pastConsZeroCount++;
        if (pastConsZeroCount == 3) {
          index = i;
          break;
        }
        continue;
      }
      if (postDecimal[i] != "0") {
        startCount = true;
        pastConsZeroCount++;
      }
    }
    print("index: $index");
    return num.toStringAsFixed(index + 1);
  }

  static String colorToHexString(Color color) {
    return color.toString();
  }

  static Color stringToColor(String color) {
    String valueString = color.split('(0x')[1].split(')')[0]; // kind of hacky..
    int value = int.parse(valueString, radix: 16);
    return new Color(value);
  }

  static checkLeadZero(double num) {
    List stringRunes = num.toString().runes.toList();
    int leadZeros = 0;
    for (var i = 0; i < stringRunes.length; ++i) {
      if (String.fromCharCode(stringRunes[i]) == "0") {
        leadZeros++;
        continue;
      }
      break;
    }
    return leadZeros;
  }

  static bool isWeekend() {
    var today = DateTime.now().weekday;
    return today == 6 || today == 7;
  }

  static bool isMarketTime() {
    Map<String, List<String>> marketOpenTimes = {
      "pst": ["06:30AM", "12:59PM"],
      "mst": ["07:30AM", "01:59PM"],
      "cst": ["08:30AM", "02:59PM"],
      "est": ["09:30AM", "03:59PM"],
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
      default:
        return null;
    }
  }

  static bool isPastPostMarket() {
    Map<String, List<String>> marketPostTimes = {
      "pst1": ["05:00PM", "11:59PM"],
      "pst2": ["12:00AM", "06:30AM"],
      "mst1": ["06:00PM", "11:59PM"],
      "mst2": ["12:00AM", "07:30AM"],
      "cst1": ["07:00PM", "11:59PM"],
      "cst2": ["12:00AM", "08:30AM"],
      "est1": ["08:00PM", "11:59PM"],
      "est2": ["12:00AM", "09:30AM"],
    };
    switch (DateTime.now().timeZoneName.toLowerCase()) {
      case "pst":
      case "pacific standard time":
      case "pdt":
      case "pacific daylight time":
        return checkTimeInRange(times: marketPostTimes['pst1']) ||
            checkTimeInRange(times: marketPostTimes["pst2"]);
      case "mst":
      case "mountain standard time":
      case "mdt":
      case "mountain daylight time":
        return checkTimeInRange(times: marketPostTimes['mst1']) ||
            checkTimeInRange(times: marketPostTimes["mst2"]);
      case "cst":
      case "central standard time":
      case "cdt":
      case "central daylight time":
        return checkTimeInRange(times: marketPostTimes['cst1']) ||
            checkTimeInRange(times: marketPostTimes["cst2"]);
      case "est":
      case "eastern standard time":
      case "edt":
      case "eastern daylight time":
        return checkTimeInRange(times: marketPostTimes['est1']) ||
            checkTimeInRange(times: marketPostTimes["est2"]);
      default:
        return null;
    }
  }

  static bool isPostMarket() {
    return (!isMarketTime() && !isPastPostMarket());
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
      closedTime = times[1];
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

  static addCommasToNum(String num) {
    return num.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  static Map maxMin(List lis) {
    Map maxMinList = {"max": 0, "min": 0};
    maxMinList['min'] =
        lis.reduce((value, element) => value < element ? value : element);
    maxMinList['max'] =
        lis.reduce((value, element) => value > element ? value : element);

    return maxMinList;
  }
}
