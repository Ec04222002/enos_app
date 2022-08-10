// news page

import 'package:enos/screens/search.dart';
import 'package:enos/services/news_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import '../models/article.dart';

class NewsPage extends StatefulWidget {
  NewsPage() {
    print(categories);
    makeArticles();
  }

  @override
  State<NewsPage> createState() => _NewsPageState();
  void makeArticles() async {
    for (int i = 0; i < categories.length; i++) {
      List<ArticleModel> lis = await NewsAPI.getArticles(categories[i], 0);
      if (i != 0) {
        slider.add(lis.first);
        lis.removeAt(0);
      }
      articles[i] = ArticleViewer(
        lis,
        categories[i],
        true,
        isSelfScroll: false,
      );
    }
  }
}

List<ArticleViewer> articles = [
  ArticleViewer([], "", true),
  ArticleViewer([], "", true),
  ArticleViewer([], "", true),
  ArticleViewer([], "", true)
];
List<String> categories = ["All", "Crypto", "Stocks", "Tech"];
List<ArticleModel> slider = [];

class _NewsPageState extends State<NewsPage> {
  TabController controller;
  List<Widget> slideShow = [];
  int tabPos = 0;

  Widget Tile(String title, String desc, String desc2, String img) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 275,
          child: Text(
            title,
            maxLines: 3,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.white),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 120,
              child: Image.network(img),
            ),
            SizedBox(
              width: 10,
            ),
            Container(
                width: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(height: 8.0),
                    Container(
                      width: 250,
                      child: Text(
                        desc,
                        maxLines: 4,
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      width: 250,
                      child: Text(
                        desc2,
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                      ),
                    ),
                  ],
                ))
          ],
        )
      ],
    );
  }

  void initState() {
    super.initState();
    for (ArticleModel m in slider) {
      DateTime time;
      time = DateTime.parse(m.datePublished).toLocal().toUtc();
      int month = time.month;
      int day = time.day;
      int year = time.year;
      int hour = time.hour;
      int minute = time.minute;
      String desc = DateFormat('hh:mm a').format(time);
      if (desc.substring(0, 1) == "0") {
        desc = desc.substring(1);
      }
      desc = desc + " - " + m.provider;

      slideShow.add(GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ArticleView(
                          postUrl: m.url,
                        )));
          },
          child: Container(
            //    height: 300,
            margin: EdgeInsets.all(12.0),
            //      padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: kLightBackgroundColor,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3.0,
                  ),
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tile(m.name, m.description, desc, m.image),
              ],
            ),
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              backgroundColor: kLightBackgroundColor,
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'News',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  ]),
            ),
            body: Container(
              color: kDarkBackgroundColor,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  // Container(
                  //   child: Text(
                  //     "Trending News",
                  //     style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.bold),
                  //   ),
                  // ),
                  Container(
                    color: kDarkBackgroundColor,
                    //         height: 210,
                    child: CarouselSlider(
                        items: slideShow,
                        options: CarouselOptions(autoPlay: true)),
                  ),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                    child: Container(
                      color: kLightBackgroundColor,
                      height: 30,
                      child: TabBar(
                        unselectedLabelColor: kDisabledColor,
                        labelColor: kBrightTextColor,
                        onTap: (int num) {
                          tabPos = num;
                          setState(() {});
                        },
                        labelPadding: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        indicator: BoxDecoration(
                            // Creates border
                            color: kActiveColor),
                        tabs: <Tab>[
                          Tab(
                            child: Text("All"),
                            height: 30,
                          ),
                          Tab(
                            child: Text("Crypto"),
                            height: 30,
                          ),
                          Tab(
                            child: Text("Stocks"),
                            height: 30,
                          ),
                          Tab(
                            child: Text("Tech"),
                            height: 30,
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        articles[0],
                        articles[1],
                        articles[2],
                        articles[3]
                      ],
                    ),
                  ))
                ]),
              ),
            )),
      ),
    );
  }
}
