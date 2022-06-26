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
    for(String s in categories) {
      List<ArticleModel> lis = await NewsAPI.getArticles(s,0);
      articles[i] = ArticleViewer(lis,s);
      i++;
    }
    print(articles.length);
  }

}
List<ArticleViewer> articles = [ArticleViewer([],""),ArticleViewer([],""),ArticleViewer([],""),ArticleViewer([],"")];
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
            bottom: TabBar(
                onTap: (int num) {
                  setState(() {

                  });
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
                children: [
                  articles[0],
                  articles[1],
                  articles[2],
                  articles[3]
                ],
            ),
          ),
        ) ,
      ),
    );
  }
}

// class NewsNav extends StatefulWidget {
//
//   @override
//   State<NewsNav> createState() => _NewsNavState();
// }
//
// class _NewsNavState extends State<NewsNav> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

//
// List<CategoryTile> getCategories() {
//   List<CategoryTile> ret = [];
//
//   CategoryTile tile = CategoryTile("All", true,0);
//   ret.add(tile);
//
//   tile = CategoryTile("Stock", false,1);
//   ret.add(tile);
//
//   tile = CategoryTile("NFT", false,2);
//   ret.add(tile);
//
//   tile = CategoryTile("Crypto", false,3);
//   ret.add(tile);
//
//   tile = CategoryTile("Tech", false,4);
//   ret.add(tile);
//   return ret;
// }
//
//
// class CategoryTile extends StatefulWidget {
//   @override
//   String text;
//   bool selected = false;
//   int index;
//
//
//   CategoryTile(String text, bool inSelect, int index) {
//     this.text = text;
//     selected = inSelect;
//     this.index = index;
//   }
//
//   State<CategoryTile> createState() => _CategoryTileState();
// }
//
// class _CategoryTileState extends State<CategoryTile> {
//   static int cSelect = 0;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(5),
//       color: Colors.blue,
//       child: TextButton(
//
//         child: Text(this.widget.text, style: TextStyle(color: Colors.white,fontSize: 18),),
//         onPressed: () {
//           setState(() {
//             this.widget.selected = true;
//             categories[cSelect].selected = false;
//             cSelect = this.widget.index;
//             print(cSelect);
//           });
//         },
//       ),
//     );
//   }
// }





