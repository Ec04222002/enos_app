
import 'package:enos/constants.dart';
import 'package:enos/models/comment.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/profile_pic.dart';
import 'package:flutter/material.dart';

import '../../models/user.dart';
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
  CommentReplyPage(UserModel user, String uid) {
    comments = [];
    this.user = user;
    this.uid = uid;
  }

  @override
  State<CommentReplyPage> createState() => _CommentReplyPageState();
}

class _CommentReplyPageState extends State<CommentReplyPage> {

  bool isLoad = false;
  void initState() {
    super.initState();
    if(widget.comments.length == 0) {
      loadComments();
    }
  }

  void loadComments() async {
    isLoad = true;
    if(widget.user == null) {
      print(widget.uid);
      widget.user = await FirebaseApi.getUser(widget.uid);
    }
    for(String com in widget.user.comments) {
      Comment comment = await FirebaseApi.getComment(com);
      widget.comments.add(comment);
    }
    widget.comments.sort((a, b) {
      return -a.createdTime.compareTo(b.createdTime);
    });
    isLoad = false;
    setState((){});
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

      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 7,),
            Text('Edit'),
            SizedBox(height: 7,),
            Expanded(
                child: isLoad? Loading():ListView.builder(
                    itemCount: widget.comments.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          commentBox(widget.comments[index]),
                          SizedBox(height: 15,)
                        ],
                      ) ;
                    }
                )
            ),
            Container(
              width: 400,
              height: 100,
              color: kLightBackgroundColor,
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.expand, color: kDisabledColor),
                      Text(
                        " Sort: ",
                        style: Theme.of(context).textTheme.caption.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kBrightTextColor),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  DefaultTabController(
                      length: 3,
                      child: Row(
                        children: [
                          Expanded(child: TabBar(
                            onTap: (int index) {
                                sort(index);
                                setState((){});
                            },
                            labelPadding: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            indicator: BoxDecoration(
                              // Creates border
                              borderRadius: BorderRadius.circular(10),
                                color: kActiveColor,),
                            tabs: [
                              Tab(
                                text: "Most Recent",
                                height: 30,
                              ),
                              Tab(
                                text: "Most Liked",
                                height: 30,
                              ),
                              Tab(
                                text: "Most Replied",
                                height: 30,
                              ),
                            ],
                          ))

                        ],
                      )
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void sort(int index) async{
    isLoad = true;
    if(index == 0) {
      widget.comments.sort((a, b) {
        return -a.createdTime.compareTo(b.createdTime);
      });
    } else if(index == 1) {
      widget.comments.sort((a, b) {
        return b.likes-a.likes;
      });
    } else {
      widget.comments.sort((a, b) {
        return b.replies.length - a.replies.length;
      });
    }
    await Future.delayed(Duration(milliseconds: 250), () {
      // Do something
    });
    isLoad = false;
    setState((){});
  }

  Widget commentBox(Comment comment) {
      return
        Row(
          children: [
            widget.user.profilePic == null? ProfilePicture(
              color1: Utils.stringToColor(widget.user.profileBgColor),
              color2: Utils.stringToColor(widget.user.profileBorderColor),
              name: widget.user.username,
            ) :
            ProfilePicture(
              color1: Utils.stringToColor(widget.user.profileBgColor),
              color2: Utils.stringToColor(widget.user.profileBorderColor),
              image: Image.network(widget.user.profilePic),
              name: widget.user.username,
            ),

            GestureDetector(
                onTap: (){

                },
                child: Container(
                  width: 350,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                      color: kLightBackgroundColor,
                      borderRadius: BorderRadius.circular(3)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.user.username.length <= 15
                                ? '${widget.user.username}'
                                : '${ widget.user.username.substring(0, 15)}...',
                            style: Theme.of(context).textTheme.caption.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: kDisabledColor),
                          ),
                          Text(
                            ' · ${Utils.getTimeFromToday(comment.createdTime)}',
                            style: Theme.of(context).textTheme.caption.copyWith(
                              color: kDisabledColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
                            child: Column(
                              children: [
                                Icon(
                                  Icons.reply_rounded,
                                  color: Colors.white,
                                ),
                                Text(
                                  '${comment.replies.length}',
                                  style: Theme.of(context).textTheme.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: kBrightTextColor,
                                      fontSize: 15.5),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 15,),
                          Container(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.thumb_up,
                                  color: Colors.white,
                                ),
                                Text(
                                  '${comment.likes}',
                                  style: Theme.of(context).textTheme.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: kBrightTextColor,
                                      fontSize: 15.5),
                                ),
                              ],
                            ),
                          ),

                        ],
                      )

                    ],
                  ),
                )
            ),


          ],
        );

  }
}

