import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants.dart';
import '../screens/search.dart';
import '../services/news_api.dart';

class ArticleModel {
  String name, url, description, datePublished, provider, image;

  ArticleModel({this.name, this.description,this.url, this.image, this.provider,this.datePublished});

  @override
  String toString() {
    return 'ArticleModel{name: $name}';
  }
}


class ArticleViewer extends StatefulWidget {
  String category;
  List<ArticleModel> articles;
  List<NewsTile> tiles = [];
  ArticleViewer(List<ArticleModel> articles, String category) {
    this.articles = articles;
    articles.forEach((m) {
      tiles.add(
          NewsTile(
            posturl: m.url,
            desc: m.description,
            img: m.image,
            title: m.name,
            provider: m.provider,
          )
      );
    });
  }
  @override
  State<ArticleViewer> createState() => _ArticleViewerState();
}

class _ArticleViewerState extends State<ArticleViewer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDarkBackgroundColor,
      child: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                itemCount: widget.tiles.length + 1,
                scrollDirection: Axis.vertical,
                  itemBuilder: (context,index) {
                    if(index < widget.tiles.length)
                        return widget.tiles[index];
                    else {
                      getNewArticles();
                      return CircularProgressIndicator();
                    }
                }
              )
          )
        ],
      ),

    );
  }

  Future<void> getNewArticles() async {
    List<ArticleModel> l = await NewsAPI.getArticles(widget.category, widget.tiles.length);
    l.forEach((m) {
      widget.tiles.add(
          NewsTile(
            posturl: m.url,
            desc: m.description,
            img: m.image,
            title: m.name,
            provider: m.provider,
          )
      );
    });
    setState((){});
  }
}

class NewsTile extends StatelessWidget {
  final String title, provider, desc, content, posturl;
  final String img;
  final Color bg = kLightBackgroundColor;

  NewsTile({this.img, this.desc, this.title, this.provider,this.content, @required this.posturl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => ArticleView(
                postUrl: posturl,
              )
          ));
        },
        child: Container(
        margin: EdgeInsets.all(12.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3.0,
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100.0,
              width: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(img),fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              padding: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text(
                provider,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.white
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              desc,
              maxLines: 3,
              style: TextStyle(color: Colors.white, fontSize: 14),
            )
          ],
        ),
      )
    );
  }
}

class ArticleView extends StatefulWidget {

     final String postUrl;
  ArticleView({@required this.postUrl});

  @override
  _ArticleViewState createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {

  final Completer<WebViewController> _controller = Completer<
      WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLightBackgroundColor,
        title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'News', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
            ]
        ),
        actions: [
          IconButton(
              iconSize: 30,
              color: kDarkTextColor.withOpacity(0.9),
              onPressed: () {
                //  NewsAPI.getArticles("crypto");
                Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchPage()));
              },
              tooltip: "Search",
              icon: Icon(Icons.search))
        ],
      ),
      body: Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: WebView(
          initialUrl: widget.postUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
        ),
      ),
    );
  }
}