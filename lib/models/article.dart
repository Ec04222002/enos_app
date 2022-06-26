import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants.dart';
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
          )
      );
    });
    setState((){});
  }
}

class NewsTile extends StatelessWidget {
  final String title, desc, content, posturl;
  final String img;
  final Color bg = Colors.blue;

  NewsTile({this.img, this.desc, this.title, this.content, @required this.posturl});

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
        color:  bg,
          margin: EdgeInsets.only(bottom: 24),
          width: MediaQuery.of(context).size.width,
          child: Container(
            color:  bg,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(6),bottomLeft:  Radius.circular(6))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(img,width: MediaQuery.of(context).size.width,height: 200,fit: BoxFit.cover,) // come here
                  ),
                  SizedBox(height: 12,),
                  Text(
                    title,
                    maxLines: 2,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    desc,
                    maxLines: 2,
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  )
                ],
              ),
            ),
          )),
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

  final Completer<WebViewController> _controller = Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Flutter",
              style:
              TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
            ),
            Text(
              "News",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
            )
          ],
        ),
        actions: <Widget>[
        Opacity(
        opacity:0,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.share,)))
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: WebView(
          initialUrl:  widget.postUrl,
          onWebViewCreated: (WebViewController webViewController){
            _controller.complete(webViewController);
          },
        ),
      ),
    );
  }
}