import 'package:flutter/material.dart';
import 'package:enos/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:enos/constants.dart';
import 'package:google_fonts/google_fonts.dart';

// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Enos",
      theme: ThemeData(
        scaffoldBackgroundColor: kDarkBackgroundColor,
        fontFamily: GoogleFonts.openSans().fontFamily,
        textTheme:
            Theme.of(context).textTheme.apply(displayColor: kDarkTextColor),
      ),
      home: HomePage(),
    );
  }
}
