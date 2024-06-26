import 'package:enos/constants.dart';
import 'package:enos/screens/account.dart';
import 'package:enos/screens/home.dart';
import 'package:enos/screens/news.dart';
import 'package:enos/screens/search.dart';

import 'package:enos/services/ticker_provider.dart';

import 'package:enos/widgets/loading.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavDisplayScreen extends StatefulWidget {
  final String uid;
  NavDisplayScreen({this.uid, Key key}) : super(key: key);

  @override
  State<NavDisplayScreen> createState() => _NavDisplayScreenState();
}

//get data for screens
//continue loading widget
class _NavDisplayScreenState extends State<NavDisplayScreen> {
  bool isLoading = true;
  int currentIndex = 0;
  final screens = [HomePage(), NewsPage(), SearchPage(), AccountPage()];

  TickerTileProvider tickerProvider = TickerTileProvider();

  Future<void> setAllData() async {
    tickerProvider.setUid(widget.uid);
    await tickerProvider.setAllInitData();
    setState(() {
      isLoading = false;

      Navigator.popUntil(
        context,
        ModalRoute.withName('/'),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    setAllData();
  }

  @override
  Widget build(BuildContext bContext) {
    if (!isLoading) {
      return Scaffold(
        body: ChangeNotifierProvider<TickerTileProvider>(
          create: (context) => tickerProvider,
          child: screens[currentIndex],
        ),
        bottomNavigationBar: SizedBox(
          height: 68,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            iconSize: 35,
            backgroundColor: kDarkBackgroundColor,
            unselectedItemColor: kDisabledColor,
            selectedItemColor: kActiveColor,
            onTap: (index) => setState(() => currentIndex = index),
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), label: 'Watchlist'),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.newspaper_sharp,
                  ),
                  label: 'News'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Account'),
            ],
          ),
        ),
      );
    }
    return Loading(
      loadText: "Setting watchlist ...",
    );
  }
}
