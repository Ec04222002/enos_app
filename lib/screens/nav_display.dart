import 'package:enos/constants.dart';
import 'package:enos/screens/account.dart';
import 'package:enos/screens/home.dart';
import 'package:enos/screens/news.dart';
import 'package:enos/screens/search.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavDisplayScreen extends StatefulWidget {
  NavDisplayScreen({Key key}) : super(key: key);

  @override
  State<NavDisplayScreen> createState() => _NavDisplayScreenState();
}

class _NavDisplayScreenState extends State<NavDisplayScreen> {
  int currentIndex = 0;
  final screens = [HomePage(), NewsPage(), SearchPage(), AccountPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        iconSize: 35,
        backgroundColor: kDarkBackgroundColor,
        unselectedItemColor: kDisabledColor,
        selectedItemColor: kActiveColor,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
