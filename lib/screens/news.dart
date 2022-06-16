// news page

import 'package:enos/screens/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}
List<CategoryTile> categories = [];
class _NewsPageState extends State<NewsPage> {

  void initState() {
    super.initState();
    categories = getCategories();
  }

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
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchPage()));
                },
                tooltip: "Search",
                icon: Icon(Icons.search))
          ]
      ),
      body: Container(
        child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,

                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  padding: EdgeInsets.all(10),
                  itemBuilder: (context,index) {
                    print('$index boo');
                    return CategoryTile(categories[index].text, categories[index].selected,index);
                  },
                ),
              )
            ],
        ),
      ),
    );
  }
}

List<CategoryTile> getCategories() {
  List<CategoryTile> ret = [];

  CategoryTile tile = CategoryTile("All", true,0);
  ret.add(tile);

  tile = CategoryTile("Stock", false,1);
  ret.add(tile);

  tile = CategoryTile("NFT", false,2);
  ret.add(tile);

  tile = CategoryTile("Crypto", false,3);
  ret.add(tile);

  tile = CategoryTile("Tech", false,4);
  ret.add(tile);
  return ret;
}


class CategoryTile extends StatefulWidget {
  @override
  String text;
  bool selected = false;
  int index;


  CategoryTile(String text, bool inSelect, int index) {
    this.text = text;
    selected = inSelect;
    this.index = index;
  }

  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  static int cSelect = 0;



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      color: Colors.blue,
      child: TextButton(
        
        child: Text(this.widget.text, style: TextStyle(color: Colors.white,fontSize: 18),),
        onPressed: () {
          setState(() {
            this.widget.selected = true;
            categories[cSelect].selected = false;
            cSelect = this.widget.index;
            print(cSelect);
          });
        },
      ),
    );
  }
}
