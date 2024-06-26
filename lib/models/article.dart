import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // Setup the listener.
    _controller.addListener(() {
      if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
        isScrollUp = true;
        return;
      }
      isScrollUp = false;
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          if (notification.metrics.extentBefore == 0 && !isScrollUp) {
            if (widget.isSelfScroll) {
              setState(() {
                widget.isSelfScroll = false;
              });
            }
            // //print("scrolling articles down -> hit top edge, moving page ");
          }
        }
        return false;
      },
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
                separatorBuilder: (context, _) => SizedBox(
                      height: 8,
                    ),
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

    // return Container(
    //   padding: EdgeInsets.zero,
    //   color: kDarkBackgroundColor,
    //   child: Column(
    //     children: <Widget>[
    //       Expanded(
    //           child: ListView.separated(
    //               separatorBuilder: (context, _) => SizedBox(
    //                     height: 8,
    //                   ),
    //               itemCount: widget.tiles.length + 1,
    //               scrollDirection: Axis.vertical,
    //               itemBuilder: (context, index) {
    //                 if (index < widget.tiles.length)
    //                   return widget.tiles[index];
    //                 else {
    //                   getNewArticles();
    //                   return CircularProgressIndicator();
    //                 }
    //               }))
    //     ],
    //   ),
    // );
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
    time = DateTime.parse(datePublished).toLocal();
    int month = time.month;
    int day = time.day;
    int year = time.year;
    // int hour = time.hour;
    // int minute = time.minute;
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ArticleView(
                        postUrl: posturl,
                        shortName: shortName != null ? shortName : "",
                      )));
        },
        child: Container(
          // margin: EdgeInsets.all(5.0),
          color: kLightBackgroundColor,
          padding: EdgeInsets.all(8.0),
          // decoration: BoxDecoration(
          //     color: bg,
          //     borderRadius: BorderRadius.circular(8.0),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black12,
          //         blurRadius: 3.0,
          //       ),
          //     ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Tile(context),
              SizedBox(
                width: 5,
              ),
              Container(
                height: 95.0,
                width: MediaQuery.of(context).size.width * 0.24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(img), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
            ],
          ),
        ));
  }

  Widget Tile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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
          padding: EdgeInsets.zero,
          width: MediaQuery.of(context).size.width * 0.64,
          child: Text(
            title,
            maxLines: 3,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
                color: Colors.white),
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          width: MediaQuery.of(context).size.width * 0.64,
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
  // final Completer<WebViewController> _controller =
  //     Completer<WebViewController>();
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          color: kDarkTextColor,
          icon: Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: kLightBackgroundColor,
        title: Text(
          widget.shortName.isNotEmpty ? widget.shortName : "News",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
