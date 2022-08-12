// news page

import 'package:enos/screens/search.dart';
import 'package:enos/services/news_api.dart';
import 'package:enos/services/yahoo_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
        // slider.add(lis.first);
        lis.removeAt(0);
      }
      articles[i] = ArticleViewer(
        lis,
        categories[i],
        true,
        isSelfScroll: false,
      );
    }

    //get popular news / slider news => 4
    dynamic response = await YahooApi().getNewsData("", 12);
    List<dynamic> streams = response['data']['main']['stream'];
    List<dynamic> urlStreams = streams
        .where((element) =>
            element['content']['clickThroughUrl'] != null &&
            element['content']['contentType'] == "STORY")
        .toList();
    //if urlStream not sufficient
    if (urlStreams.length < 3) {
      print("searching");
      for (dynamic stream in streams) {
        //setting valid link string
        String link;
        dynamic details = await YahooApi().getArticleLink(stream['id']);
        dynamic data = details['data']['contents'][0]['content'];
        List<String> links = [
          data['ampUrl'],
          data['canonicalUrl'] != null ? data['canonicalUrl']['url'] : null,
          data['clickThroughUrl'] != null
              ? data['clickThroughUrl']['url']
              : null,
        ];

        for (String l in links) {
          if (l != null && l.isNotEmpty) {
            link = l;
            break;
          }
        }
        if (link == null || link.isNotEmpty) {
          continue;
        }
        //valid link
        //add to urlStream
        stream['clickThroughUrl']['url'] = link;
        urlStreams.add(stream);
        if (urlStreams.length > 3) break;
      }
    }

    //have all valid urlstream
    for (int indx = 0; indx < streams.length; ++indx) {
      if (slider.length == 4) break;
      dynamic stream = urlStreams[indx];
      //create slider with articlemodle
      dynamic content = stream['content'];
      String imgUrl;
      if (content['thumbnail'] == null ||
          content['thumbnail']['resolutions'] == null ||
          content['thumbnail']['resolutions'].isEmpty) continue;

      int i = 0;
      while (imgUrl == null && i != 4) {
        imgUrl = content['thumbnail']['resolutions'][i]['url'];
        i++;
      }
      if (imgUrl == null) continue;
      slider.add(ArticleModel(
          uuid: stream['id'],
          name: content['title'].toString(),
          url: content['clickThroughUrl']['url'],
          image: imgUrl,
          provider: content['provider']['displayName']));
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
final List<Tab> myTabs = <Tab>[
  Tab(
    text: categories[0],
    height: 30,
  ),
  Tab(
    text: categories[1],
    height: 30,
  ),
  Tab(
    text: categories[2],
    height: 30,
  ),
  Tab(
    text: categories[3],
    height: 30,
  )
];
final double toolBarHeight = 33, bottomNavBarHeight = 68;
bool isSelfScroll = false;

class _NewsPageState extends State<NewsPage> {
  TabController controller;
  List<Widget> slideShow = [];
  int tabPos = 0;

  Widget Tag(String title, String provider) {
    return Container(
      margin: EdgeInsets.only(bottom: 22),
      padding: EdgeInsets.all(4),
      width: 220,
      height: 60,
      decoration: BoxDecoration(
        color: kDarkBackgroundColor,
        borderRadius: BorderRadius.only(
            // topLeft: Radius.circular(10),
            topRight: Radius.circular(3),
            // bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            maxLines: 2,
            text: TextSpan(
                text: title, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            height: 4,
          ),
          RichText(
              text: TextSpan(
                  text: " - $provider",
                  style: TextStyle(fontSize: 13, color: kDisabledColor)))
        ],
      ),
      // color: kDarkBackgroundColor,
    );
  }

  final ScrollController pageScrollController = ScrollController();

  void initState() {
    super.initState();

    for (ArticleModel m in slider) {
      // DateTime time;
      // time = DateTime.parse(m.datePublished).toLocal().toUtc();
      // int month = time.month;
      // int day = time.day;
      // int year = time.year;
      // int hour = time.hour;
      // int minute = time.minute;
      // String desc = DateFormat('hh:mm a').format(time);
      // if (desc.substring(0, 1) == "0") {
      //   desc = desc.substring(1);
      // }
      // desc = desc + " - " + m.provider;
      slideShow.add(GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ArticleView(
                          postUrl: m.url,
                        )));
          },
          child: Stack(alignment: AlignmentDirectional.bottomStart, children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 10, 15),
              padding: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(m.image), fit: BoxFit.fill),
                  color: kLightBackgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3.0,
                    ),
                  ]),
            ),
            Tag(m.name, m.provider),
          ])));
    }
  }

  void setArticleScroll() {
    List<ArticleViewer> newArtices = [];
    for (int i = 0; i < articles.length; ++i) {
      newArtices.add(new ArticleViewer(
        articles[i].articles,
        articles[i].category,
        true,
        isSelfScroll: isSelfScroll,
      ));
    }
    articles = newArtices;
  }

  AppBar appBar = AppBar(
        titleSpacing: 0,
        centerTitle: true,
        backgroundColor: kLightBackgroundColor,
        title: Text(
          'News',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      appBar2 = AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: toolBarHeight,
        backgroundColor: kLightBackgroundColor,
        leading: Container(height: 0),
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TabBar(
              labelPadding: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              indicator: BoxDecoration(
                  // Creates border
                  color: kActiveColor),
              tabs: myTabs,
            )
          ],
        ),
      );
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          appBar: appBar,
          body: NotificationListener(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                double after = pageScrollController.position.extentAfter;
                print(after);
                if (after == 0) {
                  if (!isSelfScroll) {
                    setState(() {
                      isSelfScroll = true;
                      setArticleScroll();
                      print("self scrolling true");
                    });
                  }
                  print(
                      "page scrolled to top sect end -> self scrolling starts");
                } else {
                  if (isSelfScroll) {
                    setState(() {
                      isSelfScroll = false;
                      setArticleScroll();
                    });
                  }
                }
              }
              return true;
            },
            //weird
            child: SingleChildScrollView(
              controller: pageScrollController,
              child: Column(children: <Widget>[
                Container(
                  color: kDarkBackgroundColor,
                  child: CarouselSlider(
                      items: slideShow,
                      options: CarouselOptions(autoPlay: true)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: Container(
                      height: MediaQuery.of(context).size.height -
                          appBar.preferredSize.height -
                          toolBarHeight -
                          bottomNavBarHeight,
                      child: Scaffold(
                        appBar: appBar2,
                        body: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: new TabBarView(
                            // controller: _tabController,
                            physics: NeverScrollableScrollPhysics(),
                            children: articles,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          )),
    );
  }
}
