import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../screens/search.dart';
import '../services/news_api.dart';
import '../widgets/loading.dart';

class ArticleModel {
  String name,
      url,
      description,
      datePublished,
      provider,
      image,
      shortName,
      uuid;
  ArticleModel(
      {this.uuid,
      this.name,
      this.shortName = "",
      this.description,
      this.url,
      this.image,
      this.provider,
      this.datePublished});

  @override
  String toString() {
    return 'ArticleModel{name: $name}';
  }
}

class ArticleViewer extends StatefulWidget {
  bool isMain;
  String category;
  List<ArticleModel> articles;
  List<NewsTile> tiles = [];

  bool isSelfScroll;
  ArticleViewer(List<ArticleModel> articles, String category, bool isMainPage,
      {this.isSelfScroll = false}) {
    isMain = isMainPage;
    this.articles = articles;
    articles.forEach((m) {
      tiles.add(NewsTile(
        shortName: m.shortName,
        posturl: m.url,
        img: m.image,
        title: m.name,
        provider: m.provider,
        datePublished: m.datePublished,
      ));
    });
  }
  @override
  State<ArticleViewer> createState() => _ArticleViewerState();
}

class _ArticleViewerState extends State<ArticleViewer> {
  final _controller = ScrollController();
  bool isScrollUp = true;
  @override
  void initState() {
    super.initState();
    // Setup the listener.
    _controller.addListener(() {
      if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
        isScrollUp = true;
        print("scrolling up");
        return;
      }
      print("scrolling down");
      isScrollUp = false;
      // print("not at top end");
      // setState(() {
      //   widget.atTop = false;
      // });
    });
  }

  Widget build(BuildContext context) {
    if (!widget.isMain) {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.extentBefore == 0 && !isScrollUp) {
              if (widget.isSelfScroll) {
                setState(() {
                  widget.isSelfScroll = false;
                });
              }
              print("scrolling articles down -> hit top edge, moving page ");
            }
          }
          return false;
        },
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  controller: _controller,
                  shrinkWrap: true,
                  itemCount: widget.tiles.length,
                  physics: widget.isSelfScroll
                      ? ClampingScrollPhysics()
                      : NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return widget.tiles[index];
                  }),
            )
          ],
        ),
      );
    }
    return Container(
      color: kDarkBackgroundColor,
      child: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: widget.tiles.length + 1,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    if (index < widget.tiles.length)
                      return widget.tiles[index];
                    else {
                      getNewArticles();
                      return CircularProgressIndicator();
                    }
                  }))
        ],
      ),
    );
  }

  Future<void> getNewArticles() async {
    List<ArticleModel> l =
        await NewsAPI.getArticles(widget.category, widget.tiles.length);
    l.forEach((m) {
      widget.tiles.add(NewsTile(
        posturl: m.url,
        img: m.image,
        title: m.name,
        provider: m.provider,
        datePublished: m.datePublished == null ? "" : m.datePublished,
        shortName: m.shortName,
      ));
    });
    setState(() {});
  }
}

class NewsTile extends StatelessWidget {
  final String title, provider, content, posturl, datePublished, shortName;
  final String img;
  final Color bg = kLightBackgroundColor;
  DateTime time;
  String desc;

  NewsTile(
      {this.img,
      this.title,
      this.provider,
      this.content,
      this.datePublished,
      this.shortName,
      this.posturl}) {
    DateTime today = DateTime.now();
    time = DateTime.parse(datePublished).toLocal().toUtc();
    int month = time.month;
    int day = time.day;
    int year = time.year;
    int hour = time.hour;
    int minute = time.minute;
    desc = DateFormat('E, MMM d, h:mm aaa').format(time);
    if (today.month == month && today.day == day && today.year == year) {
      desc = "Today " + DateFormat('h:mm aaa').format(time);
    }
    desc = desc + " - " + provider;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          print(posturl);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ArticleView(
                        postUrl: posturl,
                        shortName: shortName != null ? shortName : "",
                      )));
        },
        child: Container(
          margin: EdgeInsets.all(5.0),
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8.0),
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
              Tile(),
              SizedBox(
                width: 5,
              ),
              Container(
                height: 100.0,
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(img), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ],
          ),
        ));
  }

  Widget Tile() {
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
          child: Text(
            title,
            maxLines: 3,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.white),
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          width: 250,
          child: Text(
            desc,
            maxLines: 2,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        )
      ],
    );
  }
}

class ArticleView extends StatefulWidget {
  final String postUrl;
  String shortName;
  ArticleView({@required this.postUrl, this.shortName = ""});

  @override
  _ArticleViewState createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLightBackgroundColor,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(
            widget.shortName.isNotEmpty ? widget.shortName : "News",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          )
        ]),
        actions: [
          IconButton(
              iconSize: 30,
              color: kDarkTextColor.withOpacity(0.9),
              onPressed: () {
                //  NewsAPI.getArticles("crypto");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchPage()));
              },
              tooltip: "Search",
              icon: Icon(Icons.search))
        ],
      ),
      body: Stack(
        children: <Widget>[
          WebView(
            initialUrl: widget.postUrl,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading
              ? Center(
                  child: Loading(loadText: "Loading News ..."),
                )
              : Stack(),
        ],
      ),
    );
  }
}
