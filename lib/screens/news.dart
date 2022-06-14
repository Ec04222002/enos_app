// news page

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
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
                onPressed: () {},
                tooltip: "Search",
                icon: Icon(Icons.search))
          ]
      ),
      body: Container(
        child: Column(
            children: <Widget>[
              // categories
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: (){},
                     child: Text('All'),
                  ),

                ],

              ),
            ],
        ),
      ),
    );
  }
}

List<CategoryTile> getCategories() {
  List<CategoryTile> ret = [];
}


class CategoryTile extends StatefulWidget {
  @override
  String text;
  bool selected = false;

  CategoryTile(String text, bool inSelect) {
    this.text = text;
    selected = inSelect;
  }
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: this.widget.selected? Colors.white:Colors.blue,
      child: TextButton(
        child: Text(this.widget.text),
        onPressed: () {
          setState(() {
            this.widget.selected = true;
          });
        },
      ),
    );
  }
}
