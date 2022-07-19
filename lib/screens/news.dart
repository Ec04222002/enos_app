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
      if(i != 0) {
        slider.add(lis.first);
        lis.removeAt(0);
      }
      articles[i] = ArticleViewer(lis, categories[i]);
    }
  }
}

List<ArticleViewer> articles = [
  ArticleViewer([], ""),
  ArticleViewer([], ""),
  ArticleViewer([], ""),
  ArticleViewer([], "")
];
List<String> categories = ["All", "Crypto", "Stocks", "Tech"];
List<ArticleModel> slider = [];

// class Slideshow extends StatefulWidget {
//   List<ArticleModel> articles;
//   Slideshow({List<ArticleModel> articles});
//
//   @override
//   State<Slideshow> createState() => _SlideshowState();
// }
//
// class _SlideshowState extends State<Slideshow> {
//   PageController _pageController;
//   void initState() {
//     super.initState();
//     _pageController = PageController(viewportFraction: 0.8);
//   }
//   @override
//     Widget build(BuildContext context) {
//     int activePage = 1;
//     return PageView.builder(
//         itemCount: widget.articles.length,
//         pageSnapping: true,
//         controller: _pageController,
//         onPageChanged: (page) {
//           setState(() {
//             activePage = page;
//           });
//         },
//         itemBuilder: (context, pagePosition) {
//           return Placeholder();
//         });
//   }
// }


class _NewsPageState extends State<NewsPage> {
  TabController controller;
  List<Widget> slideShow = [];
  int tabPos = 0;

  Widget Tile(String title,String desc, String desc2) {
    return Column(
      children: <Widget>[
        // Container(
        //   padding: EdgeInsets.all(6.0),
        //   decoration: BoxDecoration(
        //     color: Colors.red,
        //     borderRadius: BorderRadius.circular(30.0),
        //   ),
        //   child: Text(
        //     provider,
        //     style: TextStyle(
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
        SizedBox(height: 8.0),
        Container(
          width: 250,
          child:Text(
            title,
            maxLines: 3,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.white
            ),
          ),
        ),
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
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ),

      ],
    );
  }
  void initState() {
    super.initState();
    for(ArticleModel m in slider) {
      DateTime time;
      time = DateTime.parse(m.datePublished).toLocal().toUtc();
      int month = time.month;
      int day = time.day;
      int year = time.year;
      int hour = time.hour;
      int minute = time.minute;
      String desc = DateFormat('hh:mm a').format(time);
      if(desc.substring(0,1) == "0") {
        desc = desc.substring(1);
      }
      desc = desc + " - " + m.provider;

      slideShow.add(
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ArticleView(
                      postUrl: m.url,
                    )
                ));
              },
              child: Container(
                height: 300,
                margin: EdgeInsets.all(12.0),
                padding: EdgeInsets.all(8.0),
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
                    Tile(m.name,m.description, desc),
                  ],
                ),
              )
          )
      );
    }
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
            // bottom: TabBar(
            //   onTap: (int num) {
            //     tabPos = num;
            //     setState(() {});
            //   },
            //   tabs: <Tab>[
            //     Tab(
            //       child: Text("All"),
            //     ),
            //     Tab(
            //       child: Text("Crypto"),
            //     ),
            //     Tab(
            //       child: Text("Stocks"),
            //     ),
            //     Tab(
            //       child: Text("Tech"),
            //     )
            //   ],
            // ),
          ),
           body: Container(
             color: kDarkBackgroundColor,
             child: Column(
                 children: <Widget>[
                   SizedBox(height: 10,),
                   Container(
                     child: Text(
                       "Trending News",

                       style: TextStyle(
                           color: Colors.white,
                         fontSize: 20,
                         fontWeight: FontWeight.bold
                       ),
                     ),
                   ) ,
                   Container(
                     color: kDarkBackgroundColor,
                     height: 200,
                     child: CarouselSlider(
                         items: slideShow,
                         options: CarouselOptions(
                             height: 300,
                             autoPlay: true
                         )
                     ),
                   ),
                   Container(

                     child: TabBar(
                       onTap: (int num) {
                         tabPos = num;
                         setState(() {});
                       },
                       indicatorPadding: EdgeInsets.all(10),
                       indicator: BoxDecoration(
                         color: Colors.lightBlue,
                         shape: BoxShape.rectangle,
                         borderRadius: BorderRadius.all(Radius.circular(8))
                       ),
                       tabs: <Tab>[
                         Tab(
                           child: Text("All"),
                         ),
                         Tab(
                           child: Text("Crypto"),
                         ),
                         Tab(
                           child: Text("Stocks"),
                         ),
                         Tab(
                           child: Text("Tech"),
                         )
                       ],
                     ),
                   ),
                   Expanded(
                       child: Container(
                         child: TabBarView(
                           children: [articles[0], articles[1], articles[2], articles[3]],
                         ),
                       )
                   )
                 ]
             ),
           )

        ),
      ),
    );
  }
}
