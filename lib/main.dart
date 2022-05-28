import 'package:enos/screens/wrapper.dart';
import 'package:enos/widgets/ticker_tile_provider.dart';
import 'package:flutter/material.dart';
import 'package:enos/constants.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initialization();
  runApp(MyApp());
}

Future initialization() async {
  await Future.delayed(Duration(seconds: 2));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  //const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TickerTileProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Enos",
        theme: ThemeData(
          scaffoldBackgroundColor: kDarkBackgroundColor,
          fontFamily: GoogleFonts.openSans().fontFamily,
          textTheme:
              Theme.of(context).textTheme.apply(displayColor: kDarkTextColor),
        ),
        home: Wrapper(),
      ),
    );
  }
}
