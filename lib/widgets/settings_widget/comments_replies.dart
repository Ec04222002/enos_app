import 'package:enos/constants.dart';
import 'package:enos/models/comment.dart';
import 'package:enos/screens/ticker_info.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';

class CommentReply extends StatelessWidget {
  const CommentReply({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 22,
        onPressed: () {},
        icon: Icon(
          Icons.arrow_forward_ios_outlined,
          color: kDarkTextColor,
        ));
  }
}

class CommentReplyPage extends StatefulWidget {
  UserModel user;
  List<Comment> comments;
  String uid;
  BuildContext context;
  TickerTileProvider provider;
  CommentReplyPage(this.user, this.context) {
    comments = [];
    provider = Provider.of<TickerTileProvider>(context, listen: false);
    uid = provider.watchListUid;
  }

  @override
  State<CommentReplyPage> createState() => _CommentReplyPageState();
}

class _CommentReplyPageState extends State<CommentReplyPage> {
  bool isLoad = true;
  List<Comment> comments = [];
  void initState() {
    if (comments.length == 0) {
      loadComments();
      super.initState();
    }
  }

  void loadComments() async {
    //print("----------");
    isLoad = true;
    comments = [];
    if (widget.user == null) {
      widget.user = await FirebaseApi.getUser(widget.uid);
    }
    // print(widget.user.comments);
    for (String com in widget.user.comments) {
      Comment comment = await FirebaseApi.getComment(com);
      //print(comment);
      //???

      comments.add(comment);
      // print(comment.parentUid);
    }

    comments.sort((a, b) {
      return -a.createdTime.compareTo(b.createdTime);
    });
    isLoad = false;
    setState(() {});
  }

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
          "Comment and Replies",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: comments.isEmpty
          ? Center(
              child: Text(
                "No comments",
                style: TextStyle(color: kDisabledColor, fontSize: 18),
              ),
            )
          : Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: showBottom,
                    child: Text(
                      "Sort",
                      style: TextStyle(color: kActiveColor, fontSize: 16),
                    ),
                  ),
                  Expanded(
                      child: isLoad
                          ? Loading()
                          : ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    commentBox(comments[index]),
                                    SizedBox(
                                      height: 15,
                                    )
                                  ],
                                );
                              })),
                ],
              ),
            ),
    );
  }

  void showBottom() {
    dynamic size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            padding: EdgeInsets.all(8),
            width: size.width,
            height: size.height * 0.15,
            color: kDarkBackgroundColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.sort, color: kDisabledColor),
                    Text(
                      " Sort",
                      style: Theme.of(context).textTheme.caption.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: kBrightTextColor),
                    )
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  color: kLightBackgroundColor,
                  child: DefaultTabController(
                      length: 3,
                      child: Row(
                        children: [
                          Expanded(
                              child: TabBar(
                            onTap: (int index) {
                              sort(index);
                              setState(() {});
                            },
                            labelPadding: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            unselectedLabelColor: kDisabledColor,
                            indicator: BoxDecoration(
                              // Creates border
                              borderRadius: BorderRadius.circular(5),
                              color: kActiveColor,
                            ),
                            tabs: [
                              Tab(
                                text: "Most Recent",
                                height: 28,
                              ),
                              Tab(
                                text: "Most Liked",
                                height: 28,
                              ),
                              Tab(
                                text: "Most Replied",
                                height: 28,
                              ),
                            ],
                          ))
                        ],
                      )),
                )
              ],
            ),
          );
        });
  }

  void sort(int index) async {
    isLoad = true;
    if (index == 0) {
      comments.sort((a, b) {
        return -a.createdTime.compareTo(b.createdTime);
      });
    } else if (index == 1) {
      comments.sort((a, b) {
        return b.likes - a.likes;
      });
    } else {
      comments.sort((a, b) {
        return b.replies.length - a.replies.length;
      });
    }
    await Future.delayed(Duration(milliseconds: 250), () {
      // Do something
    });
    isLoad = false;
    setState(() {});
  }

  Widget commentBox(Comment comment) {
    return Row(
      children: [
        widget.user.profilePic == null
            ? ProfilePicture(
                color1: Utils.stringToColor(widget.user.profileBgColor),
                color2: Utils.stringToColor(widget.user.profileBorderColor),
                name: widget.user.username,
              )
            : ProfilePicture(
                color1: Utils.stringToColor(widget.user.profileBgColor),
                color2: Utils.stringToColor(widget.user.profileBorderColor),
                image: Image.network(widget.user.profilePic),
                name: widget.user.username,
              ),
        GestureDetector(
            onTap: () async {
              // print("clicked at setting");
              // print(comment.commentUid);
              // print(comment.parentUid);

              // print(comment.isNested);
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TickerInfo(
                          symbol: comment.stockUid,
                          uid: widget.uid,
                          isSaved: widget.provider.symbols
                              .contains(comment.stockUid),
                          provider: widget.provider,
                          parentId: comment.parentUid,
                          childId: comment.commentUid)));
              widget.user = null;
              loadComments();
            },
            child: Container(
              // width: MediaQuery.of(context).size.width - 47,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                  color: kLightBackgroundColor,
                  borderRadius: BorderRadius.circular(3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.user.username.length <= 15
                            ? '${widget.user.username}'
                            : '${widget.user.username.substring(0, 15)}...',
                        style: Theme.of(context).textTheme.caption.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: kDisabledColor),
                      ),
                      Text(
                        ' · ${Utils.getTimeFromToday(comment.createdTime)} (${comment.stockUid})',
                        style: Theme.of(context).textTheme.caption.copyWith(
                              color: kDisabledColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      // Text("~ Commented on ${comment.stockUid}"),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 250,
                        child: Text(
                          '${comment.content}',
                          style: Theme.of(context).textTheme.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: kBrightTextColor,
                              fontSize: 15.5),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                        child: Column(
                          children: [
                            Icon(
                              Icons.reply_rounded,
                              color: kDarkTextColor,
                              size: 27,
                            ),
                            Text(
                              '${comment.replies.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: kBrightTextColor,
                                      fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              color: kDarkTextColor,
                              size: 21,
                            ),
                            Text(
                              '${comment.likes}',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: kBrightTextColor,
                                      fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )),
      ],
    );
  }
}
