// news page

import 'package:enos/screens/search.dart';
import 'package:enos/services/news_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/article.dart';

class NewsPage extends StatefulWidget {
  NewsPage() {
    makeArticles();
  }

  @override
  State<NewsPage> createState() => _NewsPageState();
  void makeArticles() async {
    int i = 0;
    for (String s in categories) {
      List<ArticleModel> lis = await NewsAPI.getArticles(s, 0);
      articles[i] = ArticleViewer(lis, s, true);
      i++;
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

class _NewsPageState extends State<NewsPage> {
  TabController controller;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
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
            // actions: [
            //   IconButton(
            //       iconSize: 30,
            //       color: kDarkTextColor.withOpacity(0.9),
            //       onPressed: () {
            //         //  NewsAPI.getArticles("crypto");
            //         Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchPage()));
            //       },
            //       tooltip: "Search",
            //       icon: Icon(Icons.search))
            // ],
            bottom: TabBar(
              onTap: (int num) {
                setState(() {});
              },
              tabs: <Tab>[
                Tab(
                  child: Text("All"),
                ),
                Tab(
                  child: Text("Crypto"),
                ),
                Tab(
                  child: Text("Stock"),
                ),
                Tab(
                  child: Text("Tech"),
                )
              ],
            ),
          ),
          body: Container(
            child: TabBarView(
              children: [articles[0], articles[1], articles[2], articles[3]],
            ),
          ),
        ),
      ),
    );
  }
}
