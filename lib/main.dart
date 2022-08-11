import 'package:enos/screens/auth_wrapper.dart';
import 'package:enos/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  await Future.delayed(Duration(seconds: 1));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  //const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        StreamProvider(
            initialData: null,
            create: (context) => context.read<AuthService>().authChanges),
        ChangeNotifierProvider(create: (context) => GoogleSignInProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Enos",
        theme: ThemeData(
          primaryColor: kDarkBackgroundColor,
          scaffoldBackgroundColor: kDarkBackgroundColor,
          fontFamily: GoogleFonts.openSans().fontFamily,
          textTheme: TextTheme(
              //slight bold or normal
              headline1:
                  TextStyle(color: kDarkTextColor, fontWeight: FontWeight.bold),
              // small text
              bodyText2: TextStyle(color: kDarkTextColor)),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}
