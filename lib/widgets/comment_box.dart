import 'package:enos/constants.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/comment_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/comment.dart';

class CommentBox extends StatefulWidget {
  final BuildContext context;
  final Comment data;
  final CommentManager manager;
  final Function() notifyParent;
  String time;
  CommentBox(
      {this.context, this.data, this.manager, @required this.notifyParent}) {
    time = Utils.getTimeFromToday(data.createdTime);
  }

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  TextEditingController _controller;

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  double width;
  double height;
  final double profileWidth = 35;
  final double postBtnWidth = 65;
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return box();
  }

  Widget box() {
    print('gay');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
              color: kLightBackgroundColor,
              borderRadius: BorderRadius.circular(3)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.data.userName.length <= 15
                        ? '${widget.data.userName}'
                        : '${widget.data.userName.substring(0, 15)}...',
                    style: Theme.of(context).textTheme.caption.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: kDisabledColor),
                  ),
                  Text(
                    ' · ${widget.time}',
                    style: Theme.of(context).textTheme.caption.copyWith(
                          color: kDisabledColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                '${widget.data.content}',
                style: Theme.of(context).textTheme.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: kBrightTextColor,
                    fontSize: 15.5),
              ),
              SizedBox(
                height: 8,
              ),
              DefaultTextStyle(
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                child: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      widget.manager.userProfilePic,
                      Container(
                        width: 90,
                        color: kLightBackgroundColor,
                        //             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: null,
                          onChanged: (String s) {
                            setState(() {});
                           },
                          onEditingComplete: () async {},
                          style:
                              TextStyle(fontSize: 12, color: kBrightTextColor),
                          decoration: InputDecoration(
                              hintText: "Reply ... ",
                              hintStyle: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      Container(
                        width: 100,
                        // height: 40,
                        child: TextButton(
                          onPressed: () async {
                            if (_controller.text != "") {
                              UserModel user = widget.manager.user;

                              Comment com = Comment(
                                  content: "@${widget.data.userName} ${_controller.value.text}",
                                  userUid: user.userUid,
                                  stockUid: widget.data.stockUid,
                                  likes: 0,
                                  isNested: true,
                                  apiComment: false,
                                  createdTime: DateTime.now(),
                                  replies: [],
                                  userName: user.username);

                              String id = await FirebaseApi.updateComment(com);
                              widget.manager.root.replies.add(id);
                              await FirebaseApi.updateComment(
                                  widget.manager.root);
                              await widget.manager.loadComments(1);
                              user.comments.add(id);
                              await FirebaseApi.updateUserData(user);
                              _controller.clear();
                              widget.notifyParent();
                              setState(() {});
                            }
                          },
                          child: Text(
                            "POST",
                            style: TextStyle(
                                color: _controller.text == ""
                                    ? kDisabledColor
                                    : kActiveColor,
                                fontSize: 12),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            UserModel user = widget.manager.user;
                            if (user.likedComments
                                .contains(widget.data.commentUid)) {
                              user.likedComments.remove(widget.data.commentUid);
                              widget.data.likes--;
                            } else {
                              user.likedComments.add(widget.data.commentUid);
                              widget.data.likes++;
                            }
                            await FirebaseApi.updateUserData(user);
                            await FirebaseApi.updateComment(widget.data);
                            widget.notifyParent();
                          },
                          icon: Row(
                            children: [
                              widget.manager.user.likedComments == null ||
                                  widget.manager.user.likedComments
                                      .contains(widget.data.commentUid)
                                  ? Icon(
                                Icons.thumb_up,
                                size: 20,
                              )
                                  : Icon(
                                Icons.thumb_up_alt_outlined,
                                size: 20,
                              ),
                              SizedBox(width: 4,),
                              Text(
                                "${widget.data.likes}",
                                style: TextStyle(fontSize: 13),
                              )
                            ],
                          ),
                          color: kDarkTextColor),
                      // SizedBox(
                      //   width: 24,
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
          !widget.manager.isLoad && widget.data.viewReply? TextButton(
                    onPressed: () async {
                      widget.manager.isLoad = true;
                      setState((){});
                      await widget.manager.loadComments(4);
                      widget.notifyParent();
                    },
                    child: Text(
                      "View More Replies",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ))
                : widget.data.viewReply? CircularProgressIndicator(color: Colors.white, strokeWidth: 10,)
                : SizedBox.shrink()
          ],
        )
      ],
    );
  }

  void viewReply() async {
    await widget.manager.loadComments(4);
    Future.delayed(Duration(milliseconds: 100), () {
      widget.notifyParent();
      setState(() {});
    });

  }
}
